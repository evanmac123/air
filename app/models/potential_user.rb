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
    "potential user"
  end

  def convert_to_full_user! name
    ConvertToFullUser.new({
      pre_user: self, 
      name: name, 
      email: email, 
      password: SecureRandom.hex(8)
    }).convert!
  end

  def is_guest?
    false
  end

  def get_started_lightbox_displayed
    false
  end

  def show_onboarding?
    false
  end

  def tile_completions
    TileCompletion.where("1 = 0")
  end

  def completed_tiles
    Tile.where("1 = 0")
  end

  def tickets
    0
  end

  def points
    0
  end

  def last_acted_at
    updated_at
  end

  def self.search_by_invitation_code invitation_code
    potential_user = self.find_by_invitation_code invitation_code
    user = User.where(email: potential_user.email).first
    user || potential_user
  end

  def voteup_intro_seen
  end

  def share_link_intro_seen
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
