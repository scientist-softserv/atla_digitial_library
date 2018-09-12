Delayed::Worker.queue_attributes = {
  default: { priority: 10 },
  events: { priority: 0 },
  harvest: { priority: 20}
}
