require 'spec_helper'

describe BulkLoad::S3LineChopper do
  def expected_object_key
    "uploads/arbitrary_csv.csv"
  end

  def test_file_path 
    Rails.root.join("spec/support/fixtures/arbitrary_csv.csv")
  end

  before do
    mock_s3 = MockS3.install
    mock_s3.mount_file(expected_object_key, test_file_path, 100)
  end

  let(:chopper) {BulkLoad::S3LineChopper.new("some_bucket", expected_object_key)}

  it "should read a file from S3 and call a callback for each line" do
    read_lines = []
    expected_text = File.read(test_file_path)

    chopper.chop do |line|
      read_lines << line
    end

    read_lines.join("").should == expected_text
  end
end
