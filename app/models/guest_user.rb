class GuestUser < ActiveRecord::Base
  # Q: Why is GuestUser not a subclass of User?
  # A: User is an overly fat model, and an old one, and I decided that some 
  # redundancy between GuestUser's and User's APIs was an OK cost to pay for
  # not dragging in a ton of old gnarly code from User.
  #
  # Plus, common behavior between this and User is good leverage to refactor
  # stuff out of User, which User could use.
  
  belongs_to :demo
  has_many   :tile_completions, :as => :user, :dependent => :destroy
  has_many  :completed_tiles, source: :tile, through: :tile_completions
  has_many   :acts, :as => :user, :dependent => :destroy
  has_one    :converted_user, :class_name => "User", :foreign_key => :original_guest_user_id, :inverse_of => :original_guest_user
  has_many   :user_in_raffle_infos, as: :user

  include CancelAccountToken
  include User::FakeUserBehavior

  def is_guest?
    true
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

  def to_ticket_progress_calculator
    TicketProgressCalculator.new(self)
  end

  def update_last_acted_at
    update_attributes(last_acted_at: Time.now)
  end

  def update_points(bump, *args)
    PointIncrementer.new(self, bump).update_points
  end

  def data_for_mixpanel
    {
      distinct_id:  "guest_user_#{self.id}",
      user_type:    self.highest_ranking_user_type,
      game:         self.demo.try(:id),
      is_test_user: is_test_user?,
      board_type:   (self.demo.try(:is_paid) ? "Paid" : "Free")
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
      :id => id
    }
  end

  def convert_to_full_user!(name, email, password, location_name = nil)
    ConvertToFullUser.new({
      pre_user: self, 
      name: name, 
      email: email, 
      password: password,
      location_name: location_name,
      converting_from_guest: true
    }).convert!
  end

  def slug
    "guestuser"
  end

  def can_start_over?
    tile_completions.first.present?
  end

  def not_show_all_completed_tiles_in_progress
    User::TileProgressCalculator.new(self).not_show_all_completed_tiles_in_progress
  end

  def voteup_intro_never_seen
    !(voteup_intro_seen)
  end

  def share_link_intro_never_seen
    !(share_link_intro_seen)
  end

  def can_see_raffle_modal?
    true
  end

  def in_board?(demo_id)
    self.demo_id == demo_id
  end
end
