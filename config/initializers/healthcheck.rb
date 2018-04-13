HealthMonitor.configure do |config|
  config.cache
  config.redis
  config.sidekiq.configure do |sidekiq_config|
    sidekiq_config.latency = 3.hours
    sidekiq_config.queue_size = 50
  end
end
