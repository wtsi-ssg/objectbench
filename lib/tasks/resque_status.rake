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
end

desc "CLear the resque errors"
task :delete_resque_errors  => :environment  do
  Resque::Failure.clear
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
     puts "#{work["exception"]}, #{work["backtrace"]}, #{work["worker"]}, #{job.reference_file}, #{job.operation}, #{ident}, #{job.length} #{job.start_time}"
     }
end

desc "Wait until there are no jobs waiting, not errors and no jobs running"
task :wait_for_stable => :environment  do
  begin
    sleep 5
    working= Resque.info[:working]
    errors = Resque.info[:failed]
    jobs   = Resque.size("job")
    floodgate = Job.floodgate
    puts "Jobs #{jobs}:Errors #{errors}:Working #{working}:Floodgate #{floodgate}"
  end while ( errors !=0 || jobs !=0 || working != 0 )
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
