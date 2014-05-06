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

task :wait_for_stable => :environment  do
  begin
    sleep 5
    working= Resque.info[:working]
    errors = Resque.info[:failed]
    jobs   = Resque.size("job")
    puts "Jobs #{jobs}:Errors #{errors}:Working #{working}"
  end while ( errors !=0 || jobs !=0 || working != 0 )
end
