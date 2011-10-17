class Friendship < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, :class_name => "User"

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
    SMS.send_message friend.phone_number, 
                     "#{user.name} has asked to follow you. Text ACCEPT #{user.sms_slug.upcase} to accept, IGNORE #{user.sms_slug.upcase} to ignore (in which case they won't be notified)"
  end

  def send_follow_notification_by_email
    Mailer.delay.follow_notification(friend.email, user.name, user.sms_slug)
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
    "OK, #{user.name} is now following you."
  end

  def ignore
    destroy
    "OK, we'll ignore the request from #{user.name} to follow you."
  end

  protected

  def first_time_friendship?(user, friend)
    FormerFriendship.where(:user_id => user.id, :friend_id => friend.id).empty?
  end

  def notify_follower_of_acceptance
    SMS.send_message(user.phone_number, friend.follow_accepted_message)
  end

  def self.pending_between(friend, options={})
    follower = if options[:follower_slug]
      User.where(:sms_slug => options[:follower_slug]).first
    elsif options[:follower_id]
      User.find(options[:follower_id])
    end

    return nil unless follower
    follower.pending_friendships.where(:friend_id => friend.id).first
  end
end
