module BulkLoadRedisKeys
  def object_key
    raise "To use BulkLoadRedisKeys in #{self.class}, you must define an #object_key method in that class"
  end

  %w(preview_queue load_queue lines_completed all_lines_chopped).each do |key_name|
    module_eval <<-END_EVAL
      def redis_#{key_name}_key
        ["bulk_upload", "#{key_name}", object_key].join(':')
      end
    END_EVAL
  end
end
