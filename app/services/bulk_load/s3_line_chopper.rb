class BulkLoad::S3LineChopper
  include BulkLoad::BulkLoadRedisKeys

  attr_reader :object_key

  def initialize(bucket_name, object_key)
    @bucket_name = bucket_name
    @object_key = object_key
  end

  def chop(&block)
    buffer = ""
    s3.buckets[@bucket_name].objects[@object_key].read do |chunk|
      buffer += chunk

      buffer.lines.each do |line|
        # TODO: This regex comparision does not work if the line only has a carriage return (\r), which has been happening in Kate's test excel files.  We need to evaluate how to do this better.
        if line =~ /\n$/
          block.call(line)
          buffer = ""
        else
          buffer = line
        end
      end
    end
  end

  private

  def s3
    unless @_s3
      @_s3 = AWS::S3.new(access_key_id: ENV['AWS_ACCESS_KEY_ID'], secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'])
    end

    @_s3
  end
end
