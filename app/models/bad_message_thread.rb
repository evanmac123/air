class BadMessageThread < ActiveRecord::Base
  has_many :messages, :class_name => 'BadMessage', :foreign_key => 'thread_id'
  has_many :replies, :through => :messages, :class_name => 'BadMessageReply'
end
