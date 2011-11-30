class Friendship < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, :class_name => "User"

  before_create :set_request_index
  after_create :send_follow_notification

  def send_follow_notification
    case friend.notification_method
    when 'sms'
      send_follow_notification_by_sms
    when 'email'
      send_follow_notification_by_email
    when 'both'
      send_follow_notification_by_sms
      send_follow_notification_by_email
    end
  end

  def send_follow_notification_by_sms
    SMS.send_message friend, follow_notification_text
  end

  def send_follow_notification_by_email
    Mailer.delay.follow_notification(
      friend.email, 
      user.name, 
      accept_command,
      ignore_command,
      (friend.demo.phone_number || TWILIO_PHONE_NUMBER).as_pretty_phone
    )
  end

  def record_follow_act
    points_from_demo = user.demo.points_for_connecting
    points_from_friend = friend.connection_bounty

    award = if points_from_demo && first_time_friendship?(user, friend)
              points_from_demo + points_from_friend
            else
              nil
            end

    self.user.acts.create(:text => "is now a fan of #{self.friend.name}", :inherent_points => award)
  end

  def create_former_friendship
    FormerFriendship.create!(:user => self.user, :friend => self.friend)
  end

  def accept
    update_attribute(:state, "accepted")
    notify_follower_of_acceptance
    record_follow_act
    create_former_friendship
    "OK, #{user.name} is now your fan."
  end

  def ignore
    destroy
    "OK, we'll ignore the request from #{user.name} to be your fan."
  end

  protected

  def first_time_friendship?(user, friend)
    FormerFriendship.where(:user_id => user.id, :friend_id => friend.id).empty?
  end

  def notify_follower_of_acceptance
    SMS.send_message(user, friend.follow_accepted_message)
  end

  def follow_notification_text
    "#{user.name} has asked to be your fan. Text\n#{accept_command} to accept,\n#{ignore_command} to ignore (in which case they won't be notified)"
  end

  def accept_command
    "YES#{request_index_text}"
  end

  def ignore_command
    "NO#{request_index_text}"
  end

  def request_index_text
    request_index && request_index > 1 ? " #{request_index}" : ""
  end

  def set_request_index
    return unless state == 'pending'
    last_request = Friendship.where(:state => 'pending', :friend_id => friend.id).order("request_index DESC").first

    self.request_index = last_request ? last_request.request_index + 1 : 1
  end

  def self.pending(friend, request_index = nil)
    all_pending = self.where(:state => 'pending', :friend_id => friend.id)

    if request_index
      all_pending.where(:request_index => request_index.to_i)
    else
      all_pending.order("created_at ASC")
    end
  end

  def self.pending_between(friend, follower_id)
    follower = User.find(follower_id)
    return nil unless follower
    follower.pending_friendships.where(:friend_id => friend.id).first
  end

  def self.accepted_between(friend, follower_id)
    follower = User.find(follower_id)
    return nil unless follower
    follower.accepted_friendships.where(:friend_id => friend.id).first
  end
end
