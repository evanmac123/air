require 'spec_helper'

describe BulkLoad::BulkLoadRedisKeys do
  class Dummy
    EXPECTED_OBJECT_KEY = 'foobar'

    include BulkLoad::BulkLoadRedisKeys

    def object_key
      EXPECTED_OBJECT_KEY
    end
  end

  let(:dummy) {Dummy.new}

  def self.expect_key(key_method, expected_key)
    describe "##{key_method}" do
      it "should return a key based on the S3 object key" do
        dummy.send(key_method).should == expected_key
      end
    end
  end

  expect_key :redis_preview_queue_key, "bulk_upload:preview_queue:#{Dummy::EXPECTED_OBJECT_KEY}"

  expect_key :redis_load_queue_key, "bulk_upload:load_queue:#{Dummy::EXPECTED_OBJECT_KEY}"

  expect_key :redis_lines_completed_key, "bulk_upload:lines_completed:#{Dummy::EXPECTED_OBJECT_KEY}"

  expect_key :redis_all_lines_chopped_key, "bulk_upload:all_lines_chopped:#{Dummy::EXPECTED_OBJECT_KEY}"

  expect_key :redis_failed_load_queue_key, "bulk_upload:failed_load_queue:#{Dummy::EXPECTED_OBJECT_KEY}"

  expect_key :redis_unique_ids_key, "bulk_upload:unique_ids:#{Dummy::EXPECTED_OBJECT_KEY}"

  expect_key :redis_user_ids_to_remove_key, "bulk_upload:user_ids_to_remove:#{Dummy::EXPECTED_OBJECT_KEY}"
end
