HealthMonitor.configure do |config|
  config.cache
  config.redis.configure do |redis_config|
    redis_config.connection = Redis.current # use your custom redis connection
  end
  config.sidekiq.configure do |sidekiq_config|
    sidekiq_config.latency = 3.hours
    sidekiq_config.queue_size = 50
  end
end
