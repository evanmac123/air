# frozen_string_literal: true

class PotentialUser < ActiveRecord::Base
  belongs_to :demo
  belongs_to :game_referrer, class_name: "User"
  belongs_to :primary_user, class_name: "User"

  has_many   :peer_invitations, as: :invitee, dependent: :delete_all
  has_one :user_intro, as: :userable, dependent: :delete

  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }
  validates_uniqueness_of :invitation_code
  before_create :set_invitation_code

  include CancelAccountToken
  include User::FakeUserBehavior
  include User::Tiles

  def is_invited_by(referrer)
    return if self.peer_invitations.length >= PeerInvitation::CUTOFF
    Mailer.invitation(self, referrer).deliver_later
    PeerInvitation.create!(inviter: referrer, invitee: self, demo: demo)
  end

  def invite_as_dependent(subject, body)
    DependentUserMailer.notify(self, subject, body).deliver_later
  end

  def email_with_name
    email
  end

  def name
    ""
  end

  def remember_token
    "token"
  end

  def slug
    "potential_user"
  end

  def mixpanel_distinct_id
    "potential_user_#{self.id}"
  end

  def data_for_mixpanel
    {
      distinct_id:     mixpanel_distinct_id,
      user_type:       self.highest_ranking_user_type,
      game:            self.demo.try(:id),
      is_test_user:    is_test_user?,
      board_type:      self.demo.try(:customer_status_for_mixpanel),
      first_time_user: false
    }
  end

  def intercom_data
    {
      user_id: id,
      name: "Guest User",
      user_hash: OpenSSL::HMAC.hexdigest("sha256", IntercomRails.config.api_secret.to_s, id.to_s)
    }
  end

  def highest_ranking_user_type
    "potential user"
  end

  def convert_to_full_user!(name)
    ConvertToFullUser.new(
      pre_user: self,
      name: name,
      email: email,
      password: SecureRandom.hex(8)
    ).convert!
  end

  def is_guest?
    false
  end

  def is_potential_user?
    true
  end

  def get_started_lightbox_displayed
    false
  end

  def display_get_started_lightbox
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

  def self.search_by_invitation_code(invitation_code)
    potential_user = self.where(invitation_code: invitation_code).first

    if potential_user
      user = User.where(email: potential_user.email).first
      user || potential_user
    end
  end

  def to_ticket_progress_calculator
    NullTicketProgressCalculator.new
  end

  def can_see_raffle_modal?
    false
  end

  protected

    def set_invitation_code
      possibly_finished = false

      until (possibly_finished && (self.valid? || self.errors[:invitation_code].empty?))
        possibly_finished = true
        self.invitation_code = Digest::SHA1.hexdigest("--#{Time.current.to_f}--#{self.email}--")
      end
    end

    class NullTicketProgressCalculator
      def initialize
      end

      def points_towards_next_threshold
        0
      end
    end
end
