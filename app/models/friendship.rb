class Friendship < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, class_name: "User"

  before_create :set_request_index
  after_create :send_follow_notification

  module State
    INITIATED = "initiated".freeze
    PENDING = "pending".freeze
    ACCEPTED = "accepted".freeze
    STATES = [INITIATED, PENDING, ACCEPTED].freeze
  end

  validates_inclusion_of :state, in: State::STATES

  def send_follow_notification
    return unless self.state == State::INITIATED

    notification_prefs = friend.board_memberships.map(&:notification_pref)

    return unless notification_prefs.include?(:email) || notification_prefs.include?(:both)

    send_follow_notification_by_email
  end

  def send_follow_notification_by_email
    Mailer.follow_notification(friend.name, friend.email, friend.reply_email_address, user.name, user.id, id).deliver_later
  end

  def record_follow_act
    self.user.acts.create(text: "are now connected with #{self.friend.name}")
    self.friend.acts.create(text: "is now connected with #{self.user.name}")
  end

  def accept
    reciprocal_friendship = self.reciprocal

    # Head off the case where they hit the 'Accept' email-button twice
    return "You are already connected with #{user.name}." if self.state == State::ACCEPTED

    # Make sure we're consistent about which of the pair call 'accept', or the wrong peeps will get emails
    return nil unless self.state == State::INITIATED && (reciprocal_friendship.state == State::PENDING)

    Friendship.transaction do
      reciprocal_friendship.update_attribute(:state, State::ACCEPTED)
      update_attribute(:state, State::ACCEPTED)
    end
    notify_follower_of_acceptance
    record_follow_act
    "OK, you are now connected with #{user.name}."
  end

  def ignore
    destroy
    self.reciprocal.destroy if self.reciprocal
    "OK, we'll ignore the request from #{user.name} to be your connection."
  end

  def reciprocal
    Friendship.where(user_id: self.friend_id, friend_id: self.user_id).first
  end

  def transition_to_new_model
    states = [self.state, self.reciprocal.try(:state)]
    case states
    when [State::PENDING, nil]
      self.update_attributes!(state: State::INITIATED)
      Friendship.create!(user: self.friend, friend: self.user, state: State::PENDING)
    when [State::PENDING, State::PENDING]
      self.update_attributes!(state: State::ACCEPTED)
      self.reciprocal.update_attributes!(state: State::ACCEPTED)
    when [State::PENDING, State::ACCEPTED]
      self.update_attributes!(state: State::ACCEPTED)
    when [State::ACCEPTED, nil]
      Friendship.create!(user: self.friend, friend: self.user, state: State::ACCEPTED)
    when [State::ACCEPTED, State::PENDING]
      self.reciprocal.update_attributes!(state: State::ACCEPTED)
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

    def notify_follower_of_acceptance
      Mailer.follow_notification_acceptance(user.name, user.email, user.reply_email_address, friend.name, friend_id).deliver_later
    end

    def follow_notification_text
      "#{user.name} has asked to be your connection. Text\n#{accept_command} to accept,\n#{ignore_command} to quietly ignore"
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
      last_request = Friendship.where(state: State::INITIATED, friend_id: friend.id).order("request_index DESC").first

      self.request_index = last_request ? last_request.request_index + 1 : 1
    end

    def self.accepted
      where(state: State::ACCEPTED)
    end

    def self.pending(friend, request_index = nil)
      all_pending = self.where(state: State::INITIATED, friend_id: friend.id)

      if request_index
        all_pending.where(request_index: request_index.to_i)
      else
        all_pending.order("created_at ASC")
      end
    end
end
