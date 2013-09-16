class FollowUpDigestEmail < ActiveRecord::Base
  serialize :tile_ids, Array

  belongs_to :demo

  def self.send_follow_up_digest_email
    where send_on: Date.today
  end
end
