class BadMessage < ActiveRecord::Base
  GROUPING_TIMEOUT = 1.hour

  belongs_to :user
  belongs_to :thread, :class_name => 'BadMessageThread', :touch => true
  has_many   :replies, :class_name => 'BadMessageReply'

  validates_presence_of :phone_number, :received_at

  before_create :set_thread

  def self.most_recent_first
    self.order('received_at DESC')
  end

  protected

  def set_thread
    return if self.thread

    recent_message = BadMessage.where('phone_number = ? AND created_at > ?', self.phone_number, Time.now - GROUPING_TIMEOUT).limit(1).first

    self.thread = recent_message.try(:thread) || BadMessageThread.create!
  end
end
