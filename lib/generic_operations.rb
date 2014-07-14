#License
#=======
#  Copyright (c) 2014 Genome Research Ltd. 
#
#    Author: James Beal <James.Beal@sanger.ac.uk>
#
#This file is part of Objectbench. 
#
#   Objectbench is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version. 
#   This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
#   You should have received a copy of the GNU General Public License along with this program. If not, see <http://www.gnu.org/licenses/>. 
#
# -*- encoding : utf-8 -*-
module GenericOperations
  require 'socket'
  include HttpHelper
  include NullStorage
  include CleversafeStorage
  include WosStorage
  include IrodsStorage

  def enqueue(job)
    size=job.length||job.size
    if (size < 10000 )
      # less than 10K
      Resque.enqueue(Job_Tiny,job.id)
      return
    end
    if (size < 1000000 )
      #Less than 1M
      Resque.enqueue(Job_Small,job.id)
      return
    end 
   if (size < 100000000 )
     #Less than 100M
     Resque.enqueue(Job_Medium,job.id)
     return
   end
   if (size < 1000000000 )
     #Less than 1G
     Resque.enqueue(Job_Large,job.id)
     return
   end  
   if (size < 10000000000 )
     #Less than 10G
     Resque.enqueue(Job_Huge,job.id)
     return
   end  
   Resque.enqueue(Job_Enormous,job.id)
  end


  def resubmit_error (exception_message: 'undefined_exception' , error: 'Undefined_error')
    if self.error_id.nil? then
     error=Error.create(  :exception=> exception_message , :reported_at => Time.now.to_f.to_s , :backtrace => caller(), :worker=> Socket.gethostname , :error => error ,  :job_id=>self.id )
     error.save
     # We don't use dup as it will copy the ASSM state
     # And we don't just resubmit the redis job as what would we
     # do if the new job failed we would have nowhere to record
     # the new error as the slot would have been taken.
     new_job=Job.new(:operation => self.operation,
                     :length => self.length,
                     :reference_file => self.reference_file,
                     :size => self.size,
                     :start => self.start,
                     :storage_type=> self.storage_type,
                     :object_identifier=> self.object_identifier,
                     :tag => self.tag )
     new_job.save
     self.enqueue(new_job)
     #self.work_error
     self.work_ends=Time.now.to_f.to_s
     self.error_id=error.id
     self.save
    end
  end

  def start_work
    self.work_starts=Time.now.to_f.to_s
    self.work_attempted
    self.save
  end

  def stop_work
    self.work_ends=Time.now.to_f.to_s
    self.work_done
    self.save
  end

  def write_operation
    logger.info  "Write #{self.id}"
    self.start_work
    case self.storage_type
    when "Null_Storage"
      self.null_write_operation
    when "Wos"
      self.wos_write_operation
    when "CleverSafe"
      self.cleversafe_write_operation
    when "Irods"
      self.irods_write_operation
    else
      raise "Unknown storage type: #{self.storage_type}, jobid #{self.id}"
    end
    if self.object_identifier.nil? 
      self.resubmit_error( error: 'No object_identifier recorded' , exception_message: 'Write_failed' )
    end
    self.stop_work
  end

  def read_operation
    logger.info  "Read #{self.id}"
    download=Tempfile.new('objectbench', ENV['OBJECTBENCH_TMPDIR'] || '/tmp',:encoding => 'ascii-8bit')
    filename=download.path
    self.start_work
    case self.storage_type
    when "Null_Storage"
      self.null_read_operation(download)
    when "Wos"
      self.wos_read_operation(download)
    when "CleverSafe"
      self.cleversafe_read_operation(download)
    when "Irods"
      self.irods_read_operation(download)
    else
      raise "Unknown storage type: #{self.storage_type}, jobid #{self.id}"
    end
    self.stop_work
    download.close
    if self.storage_type=="Null_Storage"
      download.unlink
      return
    end
    if filename.nil?
      self.resubmit_error( error: "Download path nil" , exception_message: 'Read_failed' ) ;
      return ;
    end
    begin
      verified=FileUtils.compare_file(self.reference_file,filename)
    rescue
      self.resubmit_error( error: "Verification failed" , exception_message: 'Read_failed' ) ;
      return
    end
    if ! verified
       if File.size(filename) == 0 then
         # If it was supposed to be zero length then 
         # the compare would have not failed.
         self.resubmit_error( error: "Zero Length file (#{self.reference_file})" , exception_message: 'Read_failed' ) ;
       else
         self.resubmit_error( error: "File corruption error (#{self.reference_file}- #{filename} )" , exception_message: 'Read_failed' )
       end
       if ENV['OBJECTBENCH_KEEP_BROKEN'] != 'TRUE'
          download.unlink
       end
       return 
    else
      download.unlink
      logger.info "compare succeeded for (#{self.reference_file}, #{filename} )"
    end

  end

  def seek_read_operation
    logger.info  "SeekRead #{self.id}"
    # First lets generate the file segment
    #
    segment=Tempfile.new('objectbench', ENV['OBJECTBENCH_TMPDIR'] || '/tmp',:encoding => 'ascii-8bit')
    # Save away the real reference file.
    filename=self.reference_file
    # http://www.ruby-doc.org/core-2.1.0/IO.html#method-c-binwrite ( filename, size of read, start of read )
    data=IO.binread(self.reference_file,self.size,self.start)
    segment.write(data)
    segment.close
    self.reference_file=segment.path
    self.save
    self.start_work
    case self.storage_type
    when "Null_Storage"
      self.null_seek_read_operation
    when "Wos"
      self.wos_seek_read_operation
    when "CleverSafe"
      self.read_operation
    when "Irods"
      self.irods_seek_read_operation
    else
      raise "Unknown storage type: #{self.storage_type}, jobid #{self.id}"
    end
    self.stop_work
    # Restore the old reference.
    self.reference_file=filename
    self.save
    # And this deletes the file
    segment.unlink
  end

  def init
    case self.storage_type
    when "Null_Storage"
      self.null_init
    when "Wos"
      self.wos_init
    when "CleverSafe"
      self.cleversafe_init
    when "Irods"
      self.irods_init
    else
      raise "Unknown storage type: #{self.storage_type}, jobid #{self.id}"
    end
  end

end
