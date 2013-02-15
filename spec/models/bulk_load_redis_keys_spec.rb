require 'spec_helper'

describe BulkLoadRedisKeys do
  EXPECTED_OBJECT_KEY = 'foobar'

  class Dummy
    include BulkLoadRedisKeys

    def object_key
      EXPECTED_OBJECT_KEY
    end
  end

  let(:dummy) {Dummy.new}

  describe "#redis_preview_queue_key" do
    it "should return a key based on the S3 object key" do
      dummy.redis_preview_queue_key.should == "bulk_upload:preview_queue:#{EXPECTED_OBJECT_KEY}"
    end
  end

  describe "#redis_load_queue_key" do
    it "should return a key based on the S3 object key" do
      dummy.redis_load_queue_key.should == "bulk_upload:load_queue:#{EXPECTED_OBJECT_KEY}"
    end
  end

  describe "#redis_lines_completed_key" do
    it "should return a key based on the S3 object key" do
      dummy.redis_lines_completed_key.should == "bulk_upload:lines_completed:#{EXPECTED_OBJECT_KEY}"
    end
  end

  describe "#redis_all_lines_chopped_key" do
    it "should return a key based on the S3 object key" do
      dummy.redis_all_lines_chopped_key.should == "bulk_upload:all_lines_chopped:#{EXPECTED_OBJECT_KEY}"
    end
  end
end
