Delayed::Worker.queue_attributes = {
  default: { priority: 10 },
  events: { priority: 0 },
  import: { priority: 20}
}
