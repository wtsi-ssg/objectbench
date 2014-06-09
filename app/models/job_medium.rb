class Job_Medium < Job
    @queue = :job_medium
    @redis = redis = Redis.new(:host =>ENV["OBJECTBENCH_REDIS_HOST"] , :port =>ENV["OBJECTBENCH_REDIS_PORT"] )
end
