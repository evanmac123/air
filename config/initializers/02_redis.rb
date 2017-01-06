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

Nest.class_eval do
  def initialize(key, redis = $redis)
    super(key.to_param)
    @redis = redis
  end

  def [](key)
    self.class.new("#{self}:#{key.to_param}", @redis)
  end
end

ActiveRecord::Base.class_eval do
  def rdb
    Nest.new(self.class.name)[id]
  end

  def self.rdb
    Nest.new(name)
  end
end

# Nest is a very simple library, which is why we feel confortable monkeypatching here.  Link to full library: https://github.com/soveran/nest/blob/master/lib/nest.rb
