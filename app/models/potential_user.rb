class PotentialUser < ActiveRecord::Base
  belongs_to :demo
  belongs_to :game_referrer, class_name: "User"
  has_many   :peer_invitations, as: :invitee
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i}
  validates_uniqueness_of :invitation_code
  before_create :set_invitation_code

  def is_invited_by referrer 
    Mailer.delay_mail(:invitation, self, referrer)
    PeerInvitation.create!(inviter: referrer, invitee: self, demo: demo)
  end

  def email_with_name
    email
  end

  def name
    ""
  end

  def unclaimed?
    true
  end

  def claimed?
    false
  end

  def ping_page(page, additional_properties = {})
    TrackEvent.ping_page(page, additional_properties, self)
  end

  def is_site_admin
    false
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

  def is_test_user?
    false
  end

  def is_guest?
    false
  end

  def accepted_friends
    User.where("id IS NULL")
  end

  def on_first_login
    true
  end

  def get_started_lightbox_displayed
    true  # it will be displayed to user
  end

  def show_onboarding?
    true
  end

  def tile_completions
    TileCompletion.where("1 = 0")
  end

  def points
    0
  end

  def available_tiles_on_current_demo
    User::TileProgressCalculator.new(self).available_tiles_on_current_demo
  end

  def completed_tiles_on_current_demo
    User::TileProgressCalculator.new(self).completed_tiles_on_current_demo
  end

  def completed_tiles
    Tile.where("1 = 0")
  end

  def tickets
    0
  end

  def has_friends
    false
  end

  def authorized_to?(page_class)
    false
  end

  def not_in_any_paid_boards?
    false
  end

  def is_client_admin_in_any_board
    false
  end

  def can_open_board_settings?
    false
  end

  def avatar
    User::NullAvatar.new
  end

  def can_switch_boards?
    false
  end

  def nerf_links_with_login_modal?
    false
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
