require 'spec_helper'

describe S3LineChopper do
  BUCKET_NAME = "test_bucket"
  OBJECT_KEY = "uploads/proprietary_data.csv"
  FIXTURE_FILENAME = "spec/support/fixtures/arbitrary_csv.csv"

  before do
    mock_s3 = MockS3.install
    mock_s3.mount_file(OBJECT_KEY, FIXTURE_FILENAME, 100)

    @chopper = S3LineChopper.new(BUCKET_NAME, OBJECT_KEY)
  end

  it "should read a file from S3 and call a callback for each line" do
    read_lines = []
    expected_text = File.read(FIXTURE_FILENAME)

    @chopper.chop do |line|
      read_lines << line
    end

    read_lines.join("").should == expected_text
  end

  it "should have some kind of way of indicating that it's done"
end
