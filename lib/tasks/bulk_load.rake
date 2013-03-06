desc "Bulk load users into a demo from a CSV uploaded to S3"
task :bulk_load, [:bucket, :object_key, :demo_id, :unique_id] => :environment do |task, args|
  # have to do this with optparse since commas in the schema fuck up rake's
  # usual bracketed argument parsing

  schema = nil
  optparse = OptionParser.new do |opts|
    opts.on('-s', '--schema ARG', 'schema, with attribute names separated with commas') do |_schema|
      schema = _schema
    end
  end

  begin
    optparse.parse!

    unless schema
      puts "Must specify schema with -s or --schema option"
      exit
    end

  rescue OptionParser::InvalidOption, OptionParser::MissingArgument
    puts $!.to_s
    puts optparse
    exit  
  end

  %w(bucket object_key demo_id unique_id).each do |arg_name|
    unless args[arg_name.to_sym].present?
      raise ArgumentError.new("must pass all arguments to bulk_load")
    end
  end

  bucket = args[:bucket]
  object_key = args[:object_key]
  demo_id = args[:demo_id]
  unique_id = args[:unique_id]

  puts "SCHEMA IS #{schema.inspect}"
  chopper = S3LineChopperToRedis.new(bucket, object_key)
  puts "Preparing to chop the file at #{bucket}/#{object_key} into Redis."
  chopper.feed_to_redis

  puts "Chopping finished! #{chopper.count} lines loaded into Redis."
  puts "Scheduling load into demo #{demo_id}. This may take some time."
  feeder = UserCreatorFeeder.new(object_key, demo_id, schema, unique_id)
  job = feeder.delay.feed
  puts "Job ID for feeder is #{job.id}"
end
