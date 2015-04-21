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
  chopper = BulkLoad::S3CensusChopper.new(bucket, object_key, unique_id_index)
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

    desc "Remove a user from the list of users to remove"
    task :retain, [:object_key, :user_id] => :environment do |task, args|
      ensure_all_arguments(task, args, %w(object_key user_id))

      retainer = BulkLoad::UserRetainer.new(args[:object_key])
      retainer.retain_user(args[:user_id])
    end

    desc "Kick off removals"
    task :start_removal, [:object_key, :demo_id, :unique_id] => :environment do |task, args|
      ensure_all_arguments(task, args, %w(object_key demo_id unique_id))

      remover = BulkLoad::UserRemover.new(args[:demo_id], args[:object_key], args[:unique_id])
      board = Demo.find(args[:demo_id])

      confirmation_string = "Yes, I want to delete users from board #{board.name}."

      puts
      puts
      puts "WARNING! THIS IS A DESTRUCTIVE AND IRREVOCABLE ACTION."
      puts "You should consider running rake bulk_load:remove:preview first to see who will be deleted."
      puts "If you are ABSOLUTELY SURE that you want to remove users from this board, type the sentence below exactly, character-for-character, at the prompt:"
      puts
      puts confirmation_string
      puts
      print "> "

      user_response = STDIN.gets.chomp

      if user_response == confirmation_string
        puts
        puts "All right buddy, it's your funeral. Here we go."
        remover.remove!
      else
        puts "User response didn't match, aborting."
      end
    end
  end

  desc "Add existing users to another board in bulk, from a CSV (one user ID per line) on S3"
  task :add_to_board, [:bucket, :object_key, :demo_id] => :environment do |task, args|
    ensure_all_arguments(task, args, %w(bucket object_key demo_id))
    chopper = BulkLoad::S3BoardAdditionChopper.new(args[:bucket], args[:object_key], args[:demo_id])
    chopper.add_users_to_board
  end
end
