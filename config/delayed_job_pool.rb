# frozen_string_literal: true

# rubocop:disable Rails/Output
# Rails helpers are not available at this point of loading the application
worker_group(:default) do |g|
  # rubocop:disable Style/TernaryParentheses,Style/ZeroLengthPredicate,Style/NumericPredicate
  g.workers = ENV.fetch('WORKER_COUNT', 1).to_i
  g.sleep_delay = ENV.fetch('WORKER_SLEEP_DELAY', 5)
  # rubocop:enable Style/TernaryParentheses,Style/ZeroLengthPredicate,Style/NumericPredicate
end

preload_app

# This runs in the main process after it preloads the app
after_preload_app do
  puts "Main #{Process.pid} preloaded app"

  # Don't hang on to database connections from the master after we've
  # completed initialization
  ActiveRecord::Base.connection_pool.disconnect!
end

# This runs in the worker processes after it has been forked
on_worker_boot do |_worker_info|
  puts "Worker #{Process.pid} started"

  # Reconnect to the database
  ActiveRecord::Base.establish_connection
end

# This runs in the main process after a worker starts
after_worker_boot do |worker_info|
  puts "Main #{Process.pid} booted worker #{worker_info.name} with " \
        "process id #{worker_info.process_id}"
end

# This runs in the main process after a worker shuts down
after_worker_shutdown do |worker_info|
  puts "Main #{Process.pid} detected dead worker #{worker_info.name} " \
        "with process id #{worker_info.process_id}"
end
# rubocop:enable Rails/Output
