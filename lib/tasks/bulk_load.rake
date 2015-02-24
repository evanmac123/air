def ensure_all_arguments(task, args, expected_args)
  expected_args.each do |arg_name|
    unless args[arg_name.to_sym].present?
      raise ArgumentError.new("must pass all arguments to #{task.name}")
    end
  end
end

desc "Bulk load users into a demo from a CSV uploaded to S3"
task :bulk_load, [:bucket, :object_key, :demo_id, :unique_id, :schema] => :environment do |task, args|
  ensure_all_arguments(task, args, %w(bucket object_key demo_id unique_id schema))

  bucket = args[:bucket]
  object_key = args[:object_key]
  demo_id = args[:demo_id]
  unique_id = args[:unique_id]
  schema = args[:schema].split('/')

  unique_id_index = schema.find_index(unique_id.to_s)

  puts "SCHEMA IS #{schema.inspect}"
  chopper = BulkLoad::S3LineChopper.new(bucket, object_key, unique_id_index)
  puts "Preparing to chop the file at #{bucket}/#{object_key} into Redis."
  chopper.feed_to_redis

  puts "Chopping finished! #{chopper.count} lines loaded into Redis."
  puts "Scheduling load into demo #{demo_id}. This may take some time."
  feeder = BulkLoad::UserCreatorFeeder.new(object_key, demo_id, schema, unique_id, unique_id_index)
  job = feeder.delay.feed
  puts "Job ID for feeder is #{job.id}"
end

namespace :bulk_load do
  namespace :remove do

    desc "Preview list of users to remove from board"
    task :preview, [:object_key, :demo_id, :unique_id] => :environment do |task, args|
      ensure_all_arguments(task, args, %w(object_key demo_id unique_id))

      remover = BulkLoad::UserRemover.new(args[:demo_id], args[:object_key], args[:unique_id])
      remover.preview_csv
    end
  end
end
