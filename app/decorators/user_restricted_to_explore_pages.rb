class UserRestrictedToExplorePages < Draper::Decorator
  # TODO: Deprecate along with all code related to nerf_links_with_login_modal
  decorates :user
  delegate_all

  def can_switch_boards?
    false
  end

  def can_open_board_settings?
    false
  end

  def nerf_links_with_login_modal?
    true
  end

  def has_tiles_tools_subnav?
    false
  end
end
