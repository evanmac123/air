class BulkLoad::S3BoardAdditionChopper < BulkLoad::S3LineChopper
  def initialize(bucket_name, object_key, board_id)
    super(bucket_name, object_key)
    @board_id = board_id
  end

  def add_users_to_board
    chop do |user_id|
      if (user = User.find(user_id))
        user.add_board(@board_id)
      end
    end
  end
end
