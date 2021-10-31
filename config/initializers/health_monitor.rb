HealthMonitor.configure do |config|
  config.cache
  config.redis.configure do |redis_config|
    # redis_config.connection = Redis.current TODO: figure out why this doesn't work but the below does
    redis_config.url = ENV.fetch('REDIS_URL', 'redis://redis:6379')
  end
end
