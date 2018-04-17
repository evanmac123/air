# frozen_string_literal: true

class GuestUser < ActiveRecord::Base
  # Q: Why is GuestUser not a subclass of User?
  # A: User is an overly fat model, and an old one, and I decided that some
  # redundancy between GuestUser's and User's APIs was an OK cost to pay for
  # not dragging in a ton of old gnarly code from User.
  #
  # Plus, common behavior between this and User is good leverage to refactor
  # stuff out of User, which User could use.

  # Dear Phil, really dumb decision.

  belongs_to :demo

  has_many :tile_completions, as: :user, dependent: :nullify
  has_many :tile_viewings, as: :user, dependent: :nullify
  has_many :acts, as: :user, dependent: :destroy
  has_many :user_in_raffle_infos, as: :user, dependent: :delete_all

  has_one :user_intro, as: :userable, dependent: :delete

  include CancelAccountToken
  include User::FakeUserBehavior
  include User::Tiles

  def active_population_segments
    []
  end

  def is_guest?
    true
  end

  def end_user?
    false
  end

  def role
    "Guest"
  end

  def name
    "Guest User [#{id}]"
  end

  def email
    "guest_user_#{id}@example.com"
  end

  def to_param
    "guestuser"
  end

  def remember_token
    "token"
  end

  def to_ticket_progress_calculator
    TicketProgressCalculator.new(self)
  end

  def update_last_acted_at
    update_attributes(last_acted_at: Time.current)
  end

  def update_points(point_increment)
    PointIncrementer.call(user: self, increment: point_increment)
  end

  def mixpanel_distinct_id
    "guest_user_#{self.id}"
  end

  def data_for_mixpanel
    {
      distinct_id:     self.mixpanel_distinct_id,
      user_type:       self.highest_ranking_user_type,
      game:            self.demo.try(:id),
      board_type:      self.demo.try(:customer_status_for_mixpanel),
      first_time_user: self.seeing_marketing_page_for_first_time
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
    "guest"
  end

  def point_and_ticket_summary(prefix = [])
    User::PointAndTicketSummarizer.new(self).point_and_ticket_summary(prefix)
  end

  def to_guest_user_hash # used to persist this guest's information to the next request
    {
      id: id,
      demo_id: demo.try(:id)
    }
  end

  def convert_to_full_user!(name, email, password, location_name = nil)
    ConvertToFullUser.new(
      pre_user: self,
      name: name,
      email: email,
      password: password,
      location_name: location_name,
      converting_from_guest: true
    ).convert!
  end

  def slug
    "guestuser"
  end

  def can_start_over?
    tile_completions.first.present?
  end

  def can_see_raffle_modal?
    true
  end

  def in_board?(demo_id)
    self.demo_id == demo_id
  end
end
