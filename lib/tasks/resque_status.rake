#License
#=======
#  Copyright (c) 2014 Genome Research Ltd. 
#
#  Author: James Beal <James.Beal@sanger.ac.uk>
#
#This file is part of Objectbench. 
#
#  Objectbench is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version. 
#  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
#  You should have received a copy of the GNU General Public License along with this program. If not, see <http://www.gnu.org/licenses/>. 
#
require 'date'

namespace :object_bench do
desc "Displays resque status"
task :resque_status => :environment  do
  errors = Resque.info[:failed]
  jobs   = Resque.size("job")
  puts "#{jobs}:#{errors}"
end

desc "Deletes all jobs, clears the errors and clears any pending jobs"
task :delete_state => :environment  do
  Job.delete_all
  Error.delete_all
  Resque::Failure.clear
  Resque.redis.del "queue:job"
  Resque.redis.del "queue:job_enormous"
  Resque.redis.del "queue:job_huge"
  Resque.redis.del "queue:job_large"
  Resque.redis.del "queue:job_medium"
  Resque.redis.del "queue:job_small"
  Resque.redis.del "queue:job_tiny"
  Resque.redis.del "queue:failed"
end

desc "CLear the resque errors"
task :delete_resque_errors  => :environment  do
  Resque::Failure.clear
end

desc "Clear Phantom workers"
task :delete_phantom_workers   => :environment  do
  Resque.workers.select{|worker| worker.id.split(':').first==ENV['PHANTOM_HOST']}.each(&:unregister_worker)
end

desc "Persist resque errors"
task :persist_resque_errors =>  :environment  do
   persist_resque_errors
end

def persist_resque_errors(resubmit_job = :false )
    Resque::Failure.all(0,Resque::Failure.count).each { |work|
      begin
        next if work['payload']['args'][0].nil?
      rescue 
        puts "Unknown error #{work.inspect}"
        next
      end
      job=Job.find_by_id(work['payload']['args'][0])
      if job.error_id.nil? then
        error=Error.create(  :exception=> work["exception"] , :reported_at => DateTime.parse(work['failed_at']).strftime('%s') , :backtrace => work["backtrace"], :worker=> work["worker"] , :error => work["error"] ,  :job_id=>job.id )
        error.save
        if resubmit_job then
          # We don't use dup as it will copy the ASSM state
          # And we don't just resubmit the redis job as what would we
          # do if the new job failed we would have nowhere to record
          # the new error as the slot would have been taken.
            new_job=Job.new(:operation =>job.operation,
                            :length => job.length,
                            :reference_file =>job.reference_file,
                            :size =>job.size,
                            :start =>job.start,
                            :storage_type=>job.storage_type,
                            :object_identifier=>job.object_identifier,
                            :tag =>job.tag )
           new_job.save
           new_job.enqueue(new_job)
           Resque::Failure.remove(work)
        end
        job.error_id=error.id
        job.save
      end
    }
end

desc "Display resque errors"
task :display_resque_errors =>  :environment  do
  Resque::Failure.all(0,Resque::Failure.count).each { |work|
     job=Job.find_by_id(work['payload']['args'][0])
     if job.object_identifier.nil? then
       ident=""
     else
       ident=job.object_identifier.chop
     end
     puts "#{work['failed_at']}, #{work["exception"]},  #{work["error"].gsub!(/\n/,' ')}, #{work["backtrace"]}, #{work["worker"]}, #{work['payload']['args'][0]}, #{job.reference_file}, #{job.operation}, #{ident}, #{job.length}, #{job.work_starts}"
     }
end

desc "Wait until there are no jobs waiting, not errors and no jobs running"
task :wait_for_stable => :environment  do
  begin
    sleep 5
    working= Resque.info[:working]
    errors = Resque.info[:failed]
    floodgate = Job.floodgate
    jobs=0
    Resque.queues.each { |queue| 
      print "#{queue} #{Resque.size(queue)}:"
      jobs=jobs+Resque.size(queue)
    }
    puts "Errors #{errors}:Working #{working}:Floodgate #{floodgate}"
    if ENV['OBJECT_BENCH_REQUE_ON_FAILURE'] == "true"  && errors > 0 then
      # Hack to ensure we do not finish too early
      job=1
      puts "Flushing errors" 
      persist_resque_errors(resubmit_job = :true ) 
    end

  end while (  jobs !=0 || working != 0 )
end

desc "Open the floodgates to that jobs which were waiting to start can, the tiem for the job does not include the waiting time"
task :open_floodgate => :environment  do
  Job.open_floodgate
end

desc "Close the floodgates, so jobs do not start actually running, they just wait until the gates open"
task :close_floodgate => :environment  do
  Job.close_floodgate
end

task :wait_for_floodgates_to_open => :environment  do
  Job.wait_until_floodgates_open
end

desc "Display state of the floodgate"
task :show_floodgate => :environment  do
  puts Job.floodgate
end

end
