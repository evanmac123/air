case Rails.env
when 'production', 'staging', 'production_local'
  $redis = Redis.new(url: ENV['REDIS_APP'])
  $redis_bulk_upload = Redis.new(url: ENV['REDIS_BULK_UPLOAD'])
when 'development'
  $redis = Redis.new(host: 'localhost', port: 6379, db: 14)
  $redis_bulk_upload = Redis.new(host: 'localhost', port: 6379, db: 10)
when 'test'
  $redis = Redis.new(host: 'localhost', port: 6379, db: 15)
  $redis_bulk_upload = Redis.new(host: 'localhost', port: 6379, db: 10)
end

$redis.client.logger = Rails.logger
ArRedis.redis = $redis
