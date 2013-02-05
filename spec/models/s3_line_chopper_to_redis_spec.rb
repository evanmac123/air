require 'spec_helper'

describe S3LineChopperToRedis do
  EXPECTED_OBJECT_KEY = "uploads/arbitrary_csv.csv"
  TEST_FILE_PATH = Rails.root.join("spec/support/fixtures/arbitrary_csv.csv")

  before do
    mock_s3 = MockS3.install
    mock_s3.mount_file(EXPECTED_OBJECT_KEY, TEST_FILE_PATH, 100)
    @chopper = S3LineChopperToRedis.new("some_bucket", EXPECTED_OBJECT_KEY)
  
    # there is probably a better way to flush Redis
    Redis.new(url: ENV['REDISTOGO_URL']).del(@chopper.send(:redis_preview_queue_key))
  end

  describe "#redis_preview_queue_key" do
    it "should return a key based on the S3 object key" do
      @chopper.redis_preview_queue_key.should == "bulk_upload:preview:#{EXPECTED_OBJECT_KEY}"
    end
  end

  describe "#feed_to_redis" do
    it "should put each line of the S3 object into a Redis queue, up to a limit" do
      lines_to_preview = 5
      @chopper.feed_to_redis(5)

      expected_lines = File.read(TEST_FILE_PATH).lines.to_a[0, lines_to_preview]

      redis = Redis.new
      redis.llen(@chopper.redis_preview_queue_key).should == lines_to_preview
      expected_lines.each do |line|
        redis.rpop(@chopper.redis_preview_queue_key).should == line
      end
    end
  end
end
