class BulkLoad::UserRemover
  include BulkLoad::BulkLoadRedisKeys

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
    # Contrary to our usual practice, we don't memoize this with an ivar.
    # This way we can remove individual user IDs via UserRetainer#retain_user by hitting
    # $redis_bulk_upload directly and not worry about having to keep our own ivar up to
    # date with $redis_bulk_upload.
    cached = $redis_bulk_upload.smembers(redis_user_ids_to_remove_key)
    if cached.present?
      cached
    else
      compute_user_ids_to_remove
    end
  end

  def each_user_id(&blk)
    user_ids_to_remove.each{|user_id| blk.call(user_id)}
  end

  def remove!
    each_user_id do |user_id|
      user = User.find(user_id)

      if user.in_multiple_boards?
        RemoveUserFromBoard.new(user, @board_id, override_paid: true).delay.remove!
      else
        user.delay.destroy
      end
    end
  end

  def preview_csv
    puts CSV.generate_line(['id', 'name', 'email', @unique_id_field])

    each_user_id do |user_id|
      user = User.find(user_id)
      puts CSV.generate_line([user.id, user.name, user.email, user.send(@unique_id_field)])
    end
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
  end

  def cache_ids_to_remove_in_redis(ids)
    ids.each {|id| $redis_bulk_upload.sadd(redis_user_ids_to_remove_key, id) }
  end

  def unique_ids_to_keep
    @unique_ids_to_keep ||= $redis_bulk_upload.smembers(redis_unique_ids_key)
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
