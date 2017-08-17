module User::FakeUserBehavior
  def unclaimed?
    true
  end

  def claimed?
    false
  end

  def ping(event, properties={})
    data = data_for_mixpanel.merge(properties)
    TrackEvent.ping(event, data)
  end

  def is_site_admin
    false
  end

  def is_test_user?
    false
  end

  def accepted_friends
    User.where("id IS NULL")
  end

  def on_first_login
    true
  end

  def show_onboarding?
    true
  end

  def available_tiles_on_current_demo
    User::TileProgressCalculator.new(self).available_tiles_on_current_demo
  end

  def completed_tiles_on_current_demo
    User::TileProgressCalculator.new(self).completed_tiles_on_current_demo
  end

  def has_friends
    false
  end

  def authorized_to?(page_class)
    false
  end

  def not_in_any_paid_or_trial_boards?
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

  def has_tiles_tools_subnav?
    false
  end

  def display_get_started_lightbox
    !get_started_lightbox_displayed && demo.tiles.active.present?
  end

  def can_make_tile_suggestions? _demo = nil
    false
  end

  #FIXME Deprecated
  def show_submit_tile_intro!
    false
  end

  def intros
   user_intro || self.create_user_intro()
  end

  def is_potential_user?
    false
  end
end
