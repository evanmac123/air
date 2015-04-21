require 'sinatra/base'

class FakeS3App < Sinatra::Base
  [
    "/avatars/:user_id/:style/:filename", # no bucket, hostname will take care of that below
    "/:bucket/tiles/:id/:filename",
    "/:bucket/tile_thumbnails/:id/:style/:filename"
  ].each do |path|
    put path do
      "OK"
    end

    delete path do
      "OK"
    end

    post path do
      "OK"
    end
  end

  put "/:bucket/tiles/:id/:filename" do
    "OK"
  end

  delete "/:bucket/tiles/:id/:filename" do
    "OK"
  end
end

[
  ['s3.amazonaws.com', 80],
  ['s3.amazonaws.com', 443],
].each do |location|
  ShamRack.at(*location).rackup {run FakeS3App}
end

# This is a mock for classes that use the AWS::SDK S3 API.

class MockS3
  class MockS3File
    def initialize(file_path, chunk_size)
      @file_path = file_path
      @chunk_size = chunk_size
    end

    def read
      if @chunk_size && block_given?
        File.open(@file_path, "r") do |file|
          while (buffer = file.read(@chunk_size))
            yield buffer
          end
        end
      else
        File.read(@file_path)
      end
    end
  end

  class MockS3String
    def initialize(text)
      @text = text
    end

    def read
      if block_given?
        yield @text.dup
      else
        @text.dup
      end
    end
  end

  def initialize
    @objects = {}
  end

  def buckets
    self
  end

  def [](_ignored)
    self
  end

  def mount_file(object_key, file_path, chunk_size = nil)
    @objects[object_key] = MockS3File.new(file_path, chunk_size)
  end

  def mount_string(object_key, text)
    @objects[object_key] = MockS3String.new(text)
  end

  attr_reader :objects

  def self.simulate_census_file_upload(uploaded_path)
    object_key = "uploaded_user_data.csv"
    mock_s3 = MockS3.install
    mock_s3.mount_file(object_key, uploaded_path, 50)

    Redis.new.flushdb
    object_key
  end

  def self.install
    mock_s3 = self.new
    AWS::S3.stubs(:new).returns(mock_s3)
    mock_s3
  end
end
