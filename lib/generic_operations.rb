
# -*- encoding : utf-8 -*-
module GenericOperations
  #require 'digest/md5'
  include NullStorage
  include CleversafeStorage

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
    when "Woz"
      self.wos_write_operation
    when "CleverSafe"
      self.cleversafe_write_operation
    else
      raise "Unknown storage type: #{job.storage_type}, jobid #{id}"
    end
    self.stop_work
  end

  def read_operation
    logger.info  "SeekRead #{self.id}"
    download=Tempfile.new('objectbench', ENV['OBJECTBENCH_TMPDIR'] || '/tmp',:encoding => 'ascii-8bit')
    self.start_work
    case self.storage_type
    when "Null_Storage"
      self.null_read_operation(download)
    when "Woz"
      self.wos_read_operation(download)
    when "CleverSafe"
      self.cleversafe_read_operation(download)
    else
      raise "Unknown storage type: #{job.storage_type}, jobid #{id}"
    end
    self.stop_work
    download.close
    if self.storage_type="Null_Storage"
      download.unlink
      return
    end
    verified=FileUtils.compare_file(self.reference_file,download.path)
    if ! verified
      raise "File corruption error (#{self.reference_file}, #{download.path} )"
    else
      download.unlink
    end

  end

  def seek_read_operation
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
    self.read_operation
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
    when "Woz"
      self.wos_init
    when "CleverSafe"
      self.cleversafe_init
    else
      raise "Unknown storage type: #{job.storage_type}, jobid #{id}"
    end
  end

end
