class Friendship < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, :class_name => "User"

  after_create :send_follow_notification
  after_create :record_follow_act
  after_create :create_former_friendship

  def send_follow_notification
    SMS.send_message(self.friend.phone_number, "#{self.user.name} is now your fan on HEngage.") if self.friend.send_follow_notification_sms
  end

  def record_follow_act
    possible_points = user.demo.points_for_connecting
    actual_points = (possible_points && first_time_friendship?(user, friend)) ? 
                      possible_points : 
                      nil

    if actual_points
      actual_points += friend.connection_bounty
    end

    self.user.acts.create(:text => "is now a fan of #{self.friend.name}", :inherent_points => actual_points)
  end

  def create_former_friendship
    FormerFriendship.create!(:user => self.user, :friend => self.friend)
  end

  protected

  def first_time_friendship?(user, friend)
    FormerFriendship.where(:user_id => user.id, :friend_id => friend.id).empty?
  end
end
