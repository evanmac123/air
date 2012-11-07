class Friendship < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, :class_name => "User"

  before_create :set_request_index
  after_create :send_follow_notification

  # "initiated" means you are the one who asked her on a date
  # "pending" means she asked you
  # "accepted" means whomever was asked accepted, so now it's ON!

  module State
    INITIATED = "initiated".freeze
    PENDING = "pending".freeze
    ACCEPTED = "accepted".freeze
    STATES = [INITIATED, PENDING, ACCEPTED].freeze
  end

  class FollowNotification < Struct.new(:to, :follower_name, :accept_command, :ignore_command, :reply_phone_number)
    def perform
      Mailer.follow_notification(to, follower_name, accept_command, ignore_command, reply_phone_number).deliver
    end
  end

  validates_inclusion_of :state, :in => State::STATES

  def send_follow_notification
    return unless self.state == State::INITIATED
    return unless %w(both email).include?(friend.notification_method)

    send_follow_notification_by_email
  end

  def send_follow_notification_by_sms
    SMS.send_message friend, follow_notification_text
  end

  def send_follow_notification_by_email
    p "**************************** FOLLOW NOTIFY"

    Delayed::Job.enqueue FollowNotification.new(friend.email,
                                                user.name,
                                                accept_command,
                                                ignore_command,
                                                (friend.demo.phone_number || TWILIO_PHONE_NUMBER).as_pretty_phone)
    #Mailer.delay.follow_notification(
    #  friend.email,
    #  user.name,
    #  accept_command,
    #  ignore_command,
    #  (friend.demo.phone_number || TWILIO_PHONE_NUMBER).as_pretty_phone
    #)
  end

  def record_follow_act
    points_from_demo = user.demo.points_for_connecting
    points_from_friend = friend.connection_bounty

    award = if points_from_demo && first_time_friendship?(user, friend)
              points_from_demo + points_from_friend
            else
              nil
            end

    self.user.acts.create(:text => "is now friends with #{self.friend.name}", :inherent_points => award)
    self.friend.acts.create(:text => "is now friends with #{self.user.name}", :inherent_points => award)
    
  end

  def create_former_friendship
    FormerFriendship.create!(:user => self.user, :friend => self.friend)
  end

  def accept
    reciprocal_friendship = self.reciprocal
    # Make sure we're consistent about which of the pair call 'accept', or the wrong peeps will get emails
    return nil unless self.state == State::INITIATED && (reciprocal_friendship.state == State::PENDING)
    Friendship.transaction do
      reciprocal_friendship.update_attribute(:state, State::ACCEPTED)
      update_attribute(:state, State::ACCEPTED)
    end
    notify_follower_of_acceptance
    record_follow_act
    create_former_friendship
    "OK, you are now friends with #{user.name}."
  end

  def ignore
    destroy
    self.reciprocal.destroy if self.reciprocal
    "OK, we'll ignore the request from #{user.name} to be your friend."
  end
  
  def reciprocal
    Friendship.where(:user_id => self.friend_id, :friend_id => self.user_id).first
  end

  def transition_to_new_model
    states = [self.state, self.reciprocal.try(:state)]
    case states
    when [State::PENDING, nil]
      self.update_attributes!(:state => State::INITIATED)
      Friendship.create!(:user => self.friend, :friend => self.user, :state => State::PENDING)
    when [State::PENDING, State::PENDING]
      self.update_attributes!(:state => State::ACCEPTED)
      self.reciprocal.update_attributes!(:state => State::ACCEPTED)
    when [State::PENDING, State::ACCEPTED]
      self.update_attributes!(:state => State::ACCEPTED)
    when [State::ACCEPTED, nil]
      Friendship.create!(:user => self.friend, :friend => self.user, :state => State::ACCEPTED)
    when [State::ACCEPTED, State::PENDING]
      self.reciprocal.update_attributes!(:state => State::ACCEPTED)
    when [State::ACCEPTED, State::ACCEPTED]
      # Everything's cool, do nothing
    else
      raise "UNANTICIPATED CASE: STATES ARE #{states.inspect}, FRIENDSHIP ID IS #{self.id}"
    end
  end

  def self.transition_all_to_new_model
    friendships = Friendship.all

    Friendship.transaction do
      friendships.each { |friendship| friendship.transition_to_new_model }
    end
  end

  protected

  def first_time_friendship?(user, friend)
    FormerFriendship.where(:user_id => user.id, :friend_id => friend.id).empty?
  end

  def notify_follower_of_acceptance
p "**************************** OUTGOING"
    OutgoingMessage.send_message(user, friend.follow_accepted_message)
  end

  def follow_notification_text
    "#{user.name} has asked to be your friend. Text\n#{accept_command} to accept,\n#{ignore_command} to quietly ignore"
  end

  def accept_command
    "YES#{request_index_text}"
  end

  def ignore_command
    "NO#{request_index_text}"
  end

  def request_index_text
    request_index && request_index > 1 ? " #{request_index}" : ""
  end

  def set_request_index
    return unless state == State::INITIATED
    last_request = Friendship.where(:state => State::INITIATED, :friend_id => friend.id).order("request_index DESC").first

    self.request_index = last_request ? last_request.request_index + 1 : 1
  end

  def self.accepted
    where(:state => State::ACCEPTED)
  end

  def self.pending(friend, request_index = nil)
    all_pending = self.where(:state => State::INITIATED, :friend_id => friend.id)

    if request_index
      all_pending.where(:request_index => request_index.to_i)
    else
      all_pending.order("created_at ASC")
    end
  end
end
