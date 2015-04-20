require 'spec_helper'

describe BulkLoad::S3LineChopper do
  EXPECTED_OBJECT_KEY = "uploads/arbitrary_csv.csv"
  TEST_FILE_PATH = Rails.root.join("spec/support/fixtures/arbitrary_csv.csv")

  before do
    mock_s3 = MockS3.install
    mock_s3.mount_file(EXPECTED_OBJECT_KEY, TEST_FILE_PATH, 100)
  end

  let(:chopper) {BulkLoad::S3LineChopper.new("some_bucket", EXPECTED_OBJECT_KEY)}

  it "should read a file from S3 and call a callback for each line" do
    read_lines = []
    expected_text = File.read(TEST_FILE_PATH)

    chopper.chop do |line|
      read_lines << line
    end

    read_lines.join("").should == expected_text
  end
end
