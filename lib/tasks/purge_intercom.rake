namespace :intercom do
  desc "Purge users with no activity over 30 days"
  task :purge_old_users => :environment do
    segment_id = ENV['INTERCOM_OLD_USERS_SEGMENT_ID']
    unless segment_id.present?
      raise "Must set environment variable INTERCOM_OLD_USERS_SEGMENT_ID"
    end

    IntercomPurger.new(segment_id).purge!
  end
end
