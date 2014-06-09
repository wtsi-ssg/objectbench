class Job_Tiny < Job
    @queue = :job_tiny
    @redis = redis = Redis.new(:host =>ENV["OBJECTBENCH_REDIS_HOST"] , :port =>ENV["OBJECTBENCH_REDIS_PORT"] )
end
