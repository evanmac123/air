require 'spec_helper'

describe BulkLoad::S3CensusChopper do
  before do
    mock_s3 = MockS3.install
    mock_s3.mount_file(expected_object_key, test_file_path, 100)
  end

  let(:expected_object_key) {"uploads/arbitrary_csv.csv"}
  let(:test_file_path) {Rails.root.join("spec/support/fixtures/arbitrary_csv.csv")}
  let(:chopper) {BulkLoad::S3CensusChopper.new("some_bucket", expected_object_key, 1)}
  let (:lines_to_preview) {5}
  let(:line_count) {File.read(test_file_path).lines.to_a.length}

  describe "#feed_to_redis" do

    def expect_lines_in_queue(key, expected_count)
      chopper.feed_to_redis(lines_to_preview)

      expect($redis_bulk_upload.llen(key)).to eq(expected_count)

      expected_lines = File.read(test_file_path).lines.to_a[0, expected_count]
      expected_lines.each do |line|
        expect($redis_bulk_upload.rpop(key)).to eq(line)
      end
    end

    it "should put a limited number of keys into a Redis queue for preview" do
      expect_lines_in_queue(chopper.redis_preview_queue_key, lines_to_preview)
    end

    it "should put every line into a Redis queue for loading" do
      expect_lines_in_queue(chopper.redis_load_queue_key, line_count)
    end

    it "should extract the unique field of each line into a queue" do
      chopper.feed_to_redis(lines_to_preview)
      stored_ids = $redis_bulk_upload.smembers(chopper.redis_unique_ids_key)
      expected_ids = CSV.parse(File.read(test_file_path)).map{|row| row[1]}
      expect(stored_ids.sort).to eq(expected_ids.sort)
    end

    it "should have some kind of way of indicating that it's done" do
      expect($redis_bulk_upload.get(chopper.redis_all_lines_chopped_key)).to be_nil

      chopper.feed_to_redis(1) do
      end

      expect($redis_bulk_upload.get(chopper.redis_all_lines_chopped_key)).to be_present
    end
  end
end
