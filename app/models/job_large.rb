class Job_Large < Job
    @queue = :job_large
    @redis = redis = Redis.new(:host =>ENV["OBJECTBENCH_REDIS_HOST"] , :port =>ENV["OBJECTBENCH_REDIS_PORT"] )
end
