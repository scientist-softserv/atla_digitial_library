Delayed::Worker.queue_attributes = {
  default: { priority: 10 },
  events: { priority: 0 },
  import: { priority: 20}
}
Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.max_run_time = 5.days
