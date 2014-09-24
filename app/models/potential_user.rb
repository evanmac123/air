class PotentialUser < ActiveRecord::Base
  belongs_to :demo
  belongs_to :game_referrer, class_name: "User"
  has_many   :peer_invitations, as: :invitee
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i}
  validates_uniqueness_of :invitation_code
  before_create :set_invitation_code

  include CancelAccountToken
  include User::FakeUserBehavior

  def is_invited_by referrer 
    return if self.peer_invitations.length >= PeerInvitation::CUTOFF
    Mailer.delay_mail(:invitation, self, referrer)
    PeerInvitation.create!(inviter: referrer, invitee: self, demo: demo)
  end

  def email_with_name
    email
  end

  def name
    ""
  end

  def slug
    "potential_user"
  end

  def data_for_mixpanel
    {
      distinct_id:  "potential_user_#{self.id}",
      user_type:    self.highest_ranking_user_type,
      game:         self.demo.try(:name),
      is_test_user: is_test_user?
    }
  end

  def highest_ranking_user_type
    "potential_user"
  end

  def convert_to_full_user! name
    converted_user = User.new(
      name: name, 
      email: email, 
      points: points, 
      tickets: tickets, 
      get_started_lightbox_displayed: false, 
      accepted_invitation_at: Time.now, 
      characteristics: {}
    )
    converted_user.password = converted_user.password_confirmation = SecureRandom.hex(8)
    converted_user.cancel_account_token = generate_cancel_account_token(converted_user)
    if converted_user.save
      converted_user.add_board(demo_id, true)
      converted_user
    else
      converted_user.errors.messages.each do |field, error_messages|
        self.errors.set(field, error_messages.uniq) # the #uniq gets rid of duplicate password errors
      end
      nil
    end
  end

  def self.search_by_invitation_code invitation_code
    potential_user = self.find_by_invitation_code invitation_code
    user = User.where(email: potential_user.email).first
    user || potential_user
  end

  protected

  def set_invitation_code
    possibly_finished = false

    until(possibly_finished && (self.valid? || self.errors[:invitation_code].empty?))
      possibly_finished = true
      self.invitation_code = Digest::SHA1.hexdigest("--#{Time.now.to_f}--#{self.email}--")
    end
  end
end
