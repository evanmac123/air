# OPTZ: Remember these guys? Cut 'em, and BadMessageReply too. Comical!
class BadMessage < ActiveRecord::Base
  belongs_to :user, :primary_key => 'phone_number', :foreign_key => 'phone_number'
  has_many   :replies, :class_name => 'BadMessageReply'

  validates_presence_of :received_at
end
