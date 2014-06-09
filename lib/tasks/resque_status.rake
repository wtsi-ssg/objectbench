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
  Resque::Failure.clear
  Resque.redis.del "queue:job"
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
    Resque::Failure.all(0,Resque::Failure.count).each { |work|
      next if work['payload']['args'][0].nil?
      job=Job.find_by_id(work['payload']['args'][0])
      error=Error.create(  :exception=> work["exception"] , :reported_at => DateTime.parse(work['failed_at']).strftime('%s') , :backtrace => work["backtrace"], :worker=> work["worker"] , :error => work["error"] ,  :job_id=>job.id )
      error.save
      job.error_id=error.id
      job.save
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
