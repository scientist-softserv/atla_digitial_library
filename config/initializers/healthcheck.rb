HealthMonitor.configure do |config|
  config.cache
  config.redis.configure do |redis_config|
    redis_config.connection = Redis.current # use your custom redis connection
  end
end
