class PeerInvitation < ActiveRecord::Base
  belongs_to :inviter, :class_name => 'User'
  belongs_to :invitee, polymorphic: true#, :class_name => 'User'
  belongs_to :demo

  validates_presence_of :inviter_id
  validates_presence_of :invitee_id
  validates_presence_of :demo_id

  CUTOFF = 3 # max number of peer invitations we'll send to a user before we
             # start silently dropping them on the floor

  def self.between_times(start_time, end_time)
    query = where('1 = 1')

    if start_time
      query = query.where("created_at >= ?", start_time)
    end

    if end_time
      query = query.where("created_at <= ?", end_time)
    end

    query
  end
end
