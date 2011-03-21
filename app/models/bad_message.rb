class BadMessage < ActiveRecord::Base
  belongs_to :user, :primary_key => 'phone_number', :foreign_key => 'phone_number'
  has_many   :replies, :class_name => 'BadMessageReply'

  validates_presence_of :phone_number, :received_at

  before_create :set_watch_list_flag

  def username
    user ? user.name : 'unknown'
  end

  def put_on_watch_list
    update_attributes(:is_new => false, :on_watch_list => true)
  end

  def self.most_recent_first
    self.order('received_at DESC')
  end

  def self.include_user
    self.includes(:user)
  end

  def self.include_replies
    self.includes(:replies => :sender)
  end

  def self.new_messages
    self.where(:is_new => true)
  end

  def self.watch_listed
    self.where(:on_watch_list => true)
  end

  def self.without_replies
    self.where(:reply_count => 0)
  end

  protected

  def set_watch_list_flag
    self.on_watch_list = (BadMessage.where(:phone_number => phone_number, :on_watch_list => true).limit(1).count == 1)
    true
  end
end
