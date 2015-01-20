require 'spec_helper'

describe S3LineChopper do
  EXPECTED_OBJECT_KEY = "uploads/arbitrary_csv.csv"
  TEST_FILE_PATH = Rails.root.join("spec/support/fixtures/arbitrary_csv.csv")

  before do
    mock_s3 = MockS3.install
    mock_s3.mount_file(EXPECTED_OBJECT_KEY, TEST_FILE_PATH, 100)
  end

  let(:chopper) {S3LineChopper.new("some_bucket", EXPECTED_OBJECT_KEY)}

  describe "#feed_to_redis" do
    let (:lines_to_preview) {5}
    
    before(:each) do
      Redis.new.flushdb
    end
   
    def expect_lines_in_queue(key, expected_count)
      chopper.feed_to_redis(lines_to_preview)

      redis = Redis.new
      redis.llen(key).should == expected_count

      expected_lines = File.read(TEST_FILE_PATH).lines.to_a[0, expected_count]
      expected_lines.each do |line|
        redis.rpop(key).should == line
      end
    end

    it "should put a limited number of keys into a Redis queue for preview" do
      expect_lines_in_queue(chopper.redis_preview_queue_key, lines_to_preview)
    end

    it "should put every line into a Redis queue for loading" do
      expect_lines_in_queue(chopper.redis_load_queue_key, File.read(TEST_FILE_PATH).lines.to_a.length)
    end

    it "should record the number of lines processed to Redis on a running basis" do
      mock_redis = stub("Redis client", lpush: nil, set: nil)
      chopper.stubs(:redis).returns(mock_redis)

      chopper.feed_to_redis(1) do
      end

      line_count_sequence = sequence('line_count')
      1.upto(20).each do |expected_count|
        mock_redis.should have_received(:set).with(chopper.redis_lines_completed_key, expected_count).in_sequence(line_count_sequence)
      end
    end

    it "should have some kind of way of indicating that it's done" do
      Redis.new.get(chopper.redis_all_lines_chopped_key).should be_nil

      chopper.feed_to_redis(1) do
      end

      Redis.new.get(chopper.redis_all_lines_chopped_key).should be_present
    end
  end

  it "should read a file from S3 and call a callback for each line" do
    read_lines = []
    expected_text = File.read(TEST_FILE_PATH)

    chopper.chop do |line|
      read_lines << line
    end

    read_lines.join("").should == expected_text
  end
end
