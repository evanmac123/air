namespace :intercom do
  desc "Purge users with no activity over 30 days"
  task :purge_old_users => :environment do
    segment_ids = ENV['INTERCOM_OLD_USERS_SEGMENT_IDS']
    unless segment_ids.present?
      raise "Must set environment variable INTERCOM_OLD_USERS_SEGMENT_IDS=segment1[,segment2,...]"
    end

    segment_ids.split(',').each do |segment_id|
      IntercomPurger.new(segment_id).delay.purge!
    end
  end
end
