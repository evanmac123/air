class EligibilityFilePurger
  AGE_THRESHOLD = (ENV['PURGE_AGE_THRESHOLD'].try(:to_i) || 7.days).freeze

  def initialize(bucket_name = ENV['PURGE_BUCKET'])
    @bucket_name = bucket_name
    @s3 = AWS::S3.new(access_key_id: ENV['AWS_ACCESS_KEY_ID'], secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'])
  end

  def purge!
    @s3.buckets[@bucket_name].objects.delete_if do |object|
      age = Time.now - object.last_modified
      age > AGE_THRESHOLD
    end
  end
end
