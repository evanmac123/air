class BadMessageReply < ActiveRecord::Base
  belongs_to :bad_message, :counter_cache => 'reply_count'
  belongs_to :sender, :class_name => 'User'

  validates_length_of :body, :maximum => 160
  validates_presence_of :bad_message_id

  def send_to_bad_message_originator
    SMS.send(self.bad_message.phone_number, self.body)
  end
end
