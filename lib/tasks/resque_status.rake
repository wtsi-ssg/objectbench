task :resque_status => :environment  do
  errors = Resque.info[:failed]
  jobs   = Resque.size("job")
  puts "#{jobs}:#{errors}"
end

task :delete_state => :environment  do
  Job.delete_all
  Resque::Failure.clear
  Resque.redis.del "queue:job"
end

task :delete_resque_errors  => :environment  do
  Resque::Failure.clear
end

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

task :open_floodgate => :environment  do
  Job.open_floodgate
end

task :close_floodgate => :environment  do
  Job.close_floodgate
end

task :wait_for_floodgates_to_open => :environment  do
  Job.wait_until_floodgates_open
end

task :show_floodgate => :environment  do
  puts Job.floodgate
end
