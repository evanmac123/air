class Friendship < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, :class_name => "User"

  after_create :send_follow_notification
  after_create :record_follow_act

  def send_follow_notification
    SMS.send(self.friend.phone_number, "#{self.user.name} is now your fan on HEngage.") if self.friend.send_follow_notification_sms
  end

  def record_follow_act
    self.user.acts.create(:text => "is now a fan of #{self.friend.name}")
  end
end
