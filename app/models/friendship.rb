class Friendship < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, :class_name => "User"

  after_create :send_follow_notification

  def send_follow_notification
    SMS.send(self.friend.phone_number, "#{self.user.name} is now following you on HEngage.")
  end
end
