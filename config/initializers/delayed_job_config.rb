Delayed::Worker.max_attempts = 2
Delayed::Worker.default_queue_name = 'default'

Delayed::Worker.queue_attributes = {
  high_priority: { priority: -10 },
  low_priority: { priority: 10 },
  bulk_mail: { priority: 0 },
  default: { priority: 0 }
}
