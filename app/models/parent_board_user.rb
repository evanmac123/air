class ParentBoardUser < ActiveRecord::Base
  belongs_to :demo
  belongs_to :user
  has_many   :tile_completions, :as => :user, :dependent => :destroy
  has_many   :completed_tiles, source: :tile, through: :tile_completions
  has_many   :acts, :as => :user, :dependent => :destroy

  delegate  :name,
            # :highest_ranking_user_type,
            # :has_tiles_tools_subnav?,
            # :authorized_to?,
            # :is_site_admin,
            # :is_guest?,
            # :can_switch_boards?,
            # :can_open_board_settings?,
            # :email,
            # :is_client_admin,
            to: :original_user

  def available_tiles_on_current_demo
    User::TileProgressCalculator.new(self).available_tiles_on_current_demo
  end

  def completed_tiles_on_current_demo
    User::TileProgressCalculator.new(self).completed_tiles_on_current_demo
  end

  def display_get_started_lightbox
    false              
  end

  def accepted_friends
    User.where("id IS NULL")
  end

  def can_see_raffle_modal?
    false
  end

  def has_friends
    false
  end

  def is_parent_board_user?
    true
  end

  def original_user
    user
  end

  def is_site_admin
    false
  end

  def is_guest?
    false
  end

  def mixpanel_distinct_id
    "parent_board_user_#{id}"
  end

  def data_for_mixpanel
    {
      distinct_id:  mixpanel_distinct_id,
      user_type:    highest_ranking_user_type,
      game:         demo_id,
      is_test_user: is_test_user?,
      board_type:   (demo.try(:is_paid) ? "Paid" : "Free")
    }
  end

  def is_test_user?
    false
  end

  def highest_ranking_user_type
    "parent_board_user"
  end

  def ping(event, properties = {})
    data = data_for_mixpanel.merge(properties)
    TrackEvent.ping(event, data)
  end

  def ping_page(page, additional_properties = {})
    TrackEvent.ping_page(page, additional_properties, self)
  end
end
