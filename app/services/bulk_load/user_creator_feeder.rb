class BulkLoad::UserCreatorFeeder
  include BulkLoad::BulkLoadRedisKeys

  attr_reader :object_key

  def initialize(object_key, demo_id, schema, unique_id_field, unique_id_index, related_board_ids = [])
    @object_key = object_key
    @demo_id = demo_id
    @schema = schema
    @unique_id_field = unique_id_field
    @unique_id_index = unique_id_index
    @related_board_ids = related_board_ids
    @line_index = 0

    if @schema.kind_of?(String)
      @schema = CSV.parse_line(@schema)
    end
  end

  def feed
    while !done?
      line = $redis_bulk_upload.rpop(redis_load_queue_key)
      redo unless line

      @line_index += 1

      user = user_creator.create_user(line)

      if user.invalid?
        $redis_bulk_upload.lpush(redis_failed_load_queue_key, line_error_message(user))
      end
    end
  end

  def done?
    $redis_bulk_upload.get(redis_all_lines_chopped_key) == 'done' &&
    $redis_bulk_upload.llen(redis_load_queue_key) == 0
  end

  protected

  def user_creator
    unless @_user_creator
      @_user_creator = BulkLoad::UserCreatorFromCsv.new(@demo_id, @schema, @unique_id_field, @unique_id_index, @related_board_ids)
    end

    @_user_creator
  end

  def line_error_message(user)
    "Line #{@line_index}: #{user.errors.full_messages.to_sentence}"
  end
end
