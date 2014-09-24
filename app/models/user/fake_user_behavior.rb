module User::FakeUserBehavior
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
    true  # it will be displayed to ordinary user later
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

  def is_client_admin
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

  def likes_tile?(tile)
    nil
  end

  def copied_tile?(tile)
    nil
  end

  def flashes_for_next_request
    nil
  end

  def privacy_level
    'nobody'
  end

  def satisfy_tiles_by_rule(*args)
  end

  def location
  end

  def date_of_birth
  end

  def notification_method
    "n/a"
  end

  def accepted_invitation_at
    created_at
  end

  def last_acted_at
    updated_at
  end
end