Resque.redis = Redis.new(:host => ENV['OBJECTBENCH_REDIS_HOST'] || '127.0.0.1' , :port => ENV['OBJECTBENCH_REDIS_PORT'] || '6379' ,  :thread_safe => true)
