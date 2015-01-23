desc "Bulk load users into a demo from a CSV uploaded to S3"
task :bulk_load, [:bucket, :object_key, :demo_id, :unique_id, :schema] => :environment do |task, args|
  %w(bucket object_key demo_id unique_id schema).each do |arg_name|
    unless args[arg_name.to_sym].present?
      raise ArgumentError.new("must pass all arguments to bulk_load")
    end
  end

  bucket = args[:bucket]
  object_key = args[:object_key]
  demo_id = args[:demo_id]
  unique_id = args[:unique_id]
  schema = args[:schema].split('/')

  puts "SCHEMA IS #{schema.inspect}"
  chopper = BulkLoad::S3LineChopper.new(bucket, object_key)
  puts "Preparing to chop the file at #{bucket}/#{object_key} into Redis."
  chopper.feed_to_redis

  puts "Chopping finished! #{chopper.count} lines loaded into Redis."
  puts "Scheduling load into demo #{demo_id}. This may take some time."
  feeder = BulkLoad::UserCreatorFeeder.new(object_key, demo_id, schema, unique_id)
  job = feeder.delay.feed
  puts "Job ID for feeder is #{job.id}"
end
