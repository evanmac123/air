class BadMessage < ActiveRecord::Base
  belongs_to :user
  has_many   :replies, :class_name => 'BadMessageReply'

  validates_presence_of :phone_number, :received_at

  def self.most_recent_first
    self.order('received_at DESC')
  end
end
