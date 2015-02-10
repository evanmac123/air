class BulkLoad::UserRemover
  include BulkLoad::BulkLoadRedisKeys
  include BulkLoad::MemoizedRedisClient

  DEFAULT_EMAIL_WHITELIST_DOMAINS = %w(
    air.bo
    airbo.com
    hengage.com
    towerswatson.com
  )

  def initialize(board_id, object_key, unique_id_field)
    @unique_id_field = unique_id_field.to_s
    ensure_unique_id_field_is_on_whitelist

    @board_id = board_id
    @object_key = object_key
  end

  def user_ids_to_remove
    @user_ids_to_remove ||= begin
                              cached = redis.smembers(redis_user_ids_to_remove_key)
                              if cached.present?
                                cached
                              else
                                compute_user_ids_to_remove
                              end
                            end
  end

  def preview(&blk)
    user_ids_to_remove.each{|user_id| blk.call(user_id)}
  end

  protected

  attr_reader :object_key

  def compute_user_ids_to_remove
    # This interpolation is safe because, remmeber, we whitelist 
    # @unique_id_field in #initialize.
    query = board.users.
              where("users.#{@unique_id_field} NOT IN (?) OR users.#{@unique_id_field} IS NULL", unique_ids_to_keep).
              where(is_site_admin: false)

    query = email_whitelist_domains.inject(query) do |query, domain|
      query.where("users.email NOT ILIKE ?", "%@#{domain}")
    end

    ids = query.pluck(:id)
    cache_ids_to_remove_in_redis(ids)
    @user_ids_to_remove = ids
  end

  def cache_ids_to_remove_in_redis(ids)
    ids.each {|id| redis.sadd(redis_user_ids_to_remove_key, id) }
  end

  def unique_ids_to_keep
    @unique_ids_to_keep ||= Redis.new.smembers(redis_unique_id_queue_key)
  end

  def board
    @board ||= Demo.find(@board_id)
  end

  def ensure_unique_id_field_is_on_whitelist
    unless User.column_names.include?(@unique_id_field)
      raise "unique_id_field argument to BulkLoad::UserRemover#new must be the name of some column on users table"
    end
  end

  def email_whitelist_domains
    @email_whitelist_domains ||= if(from_env = ENV['BULK_UPLOAD_EMAIL_WHITELIST_DOMAINS'])
                                   from_env.split(',')
                                 else
                                   DEFAULT_EMAIL_WHITELIST_DOMAINS
                                 end
  end
end
