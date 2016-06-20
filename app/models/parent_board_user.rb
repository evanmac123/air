class ParentBoardUser < ActiveRecord::Base
  belongs_to :demo
  belongs_to :user
  has_many   :tile_completions, :as => :user, :dependent => :destroy
  has_many   :tile_viewings, :as => :user, :dependent => :destroy
  has_many   :completed_tiles, source: :tile, through: :tile_completions
  has_many   :acts, :as => :user, :dependent => :destroy

  include User::FakeUserBehavior

  delegate  :can_switch_boards?,
            :nerf_links_with_login_modal?,
            :name,
            to: :original_user

  def display_get_started_lightbox
    false              
  end

  def can_see_raffle_modal?
    false
  end

  def is_parent_board_user?
    true
  end

  def original_user
    user
  end

  def is_guest?
    false
  end

  def mixpanel_distinct_id
    "parent_board_user_#{id}"
  end

  def data_for_mixpanel
    {
      distinct_id:     mixpanel_distinct_id,
      user_type:       highest_ranking_user_type,
      game:            demo_id,
      is_test_user:    is_test_user?,
      board_type:      (demo.try(:is_paid) ? "Paid" : "Free"),
      first_time_user: false
    }
  end

  def highest_ranking_user_type
    "parent_board_user"
  end

  def to_ticket_progress_calculator
    TicketProgressCalculator.new(self)
  end

  def not_show_all_completed_tiles_in_progress
    User::TileProgressCalculator.new(self).not_show_all_completed_tiles_in_progress
  end

  def in_board?(demo_id)
    self.demo_id == demo_id
  end

  def update_last_acted_at
    update_attributes(last_acted_at: Time.now)
  end

  def update_points(bump, *args)
    PointIncrementer.new(self, bump).update_points
  end

  def can_start_over?
    false
  end

  def email
    "parent_board_user_#{id}@example.com"
  end

  def self.find_or_create params
    pb_user = where(params).first
    pb_user = create!(params) unless pb_user
    pb_user
  end
end
