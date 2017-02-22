class UserInHeaderPresenter
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::FormOptionsHelper
  include ApplicationHelper

  attr_reader :params,
              :public_tile_page,
              :current_user,
              :request

  delegate    :to_param,
              :demo,
              :demo_id,
              :authorized_to?,
              :can_open_board_settings?,
              :is_guest?,
              :can_switch_boards?,
              :has_tiles_tools_subnav?,
              :avatar,
              :name,
              :email,
              :can_make_tile_suggestions?,
              :is_client_admin,
              :is_site_admin,
              to: :current_user

  def initialize(user, public_tile_page, params, request)
    @current_user = user
    @public_tile_page = public_tile_page
    @params = params
    @request = request
  end

  def home_path
    if guest_for_tile_preview?
      nil
    elsif current_user.is_guest? && !public_tile_page
      public_activity_path(current_user.demo.public_slug)
    elsif @request.cookies["user_onboarding"].present? && current_user.user_onboarding && !current_user.user_onboarding.completed
      user_onboarding_path(current_user.user_onboarding.id, return_onboarding: true)
    else
      root_path
    end
  end

  def show_user_nav?
    current_user.is_guest? || public_tile_page
  end

  def logo_url
    demo.logo.url
  end

  def end_user?
    current_user.is_a?(User) && current_user.end_user?
  end

  def show_board_switcher?
    boards_to_switch_to.present? &&
    boards_to_switch_to.length > 1 &&
    current_user.try(:can_switch_boards?)
  end

  def options_for_board_select
    options_from_collection_for_select boards_to_switch_to, :id, :name, current_user.demo_id
  end

  def after_login_link
    if current_user.can_open_board_settings?
      ""
    else
      "#{request.path}?pop_board_settings_modal=true"
    end
  end

  def guest_user_header_button_style
    if show_save_progress_button
      ''
    else
      'display: none'
    end
  end

  def has_boards_to_switch_to?
    boards_to_switch_to.present? && boards_to_switch_to.length > 1
  end

  def can_create_board?
    current_user.is_site_admin ||
    current_user.not_in_any_paid_boards? ||
    current_user.is_client_admin_in_any_board
  end

  def has_intercom_help?
    !current_user.is_client_admin
  end

  def show_contact_airbo?
    request.url.include? 'explore' # in explore section
  end

  def show_side_menu_button?
    !current_user.is_guest?
  end

  def show_login_modal?
    current_user && !current_user.can_switch_boards?
  end

  def boards_to_switch_to
    return if is_not_user?
    if current_user.is_site_admin
      @boards_to_switch_to ||= Demo.select([:name, :id]).alphabetical
    else
      @boards_to_switch_to ||= current_user.demos.alphabetical
    end
  end

  def boards_as_admin
    return if is_not_user?
    current_user.boards_as_admin
  end

  def boards_as_regular_user
    return if is_not_user?
    current_user.boards_as_regular_user
  end

  def has_only_one_board?
    return if is_not_user?
    current_user.has_only_one_board?
  end

  def divider_class
    if put_divider_between_sections?
      "with_divider"
    else
      ""
    end
  end

  def followup_is_muted(board)
    muted_followup_boards.include?(board)
  end

  def digest_is_muted(board)
    muted_digest_boards.include?(board)
  end

  def can_submit_tile?
    (can_make_tile_suggestions? || is_client_admin || current_user.is_site_admin) &&
      ["acts", "tiles"].include?(request[:controller]) &&
      !request.original_url.include?("client_admin") &&
      !request.original_url.include?("explore")
  end

  def show_search_bar?
    if user.is_a?(User) && (user.is_client_admin || user.is_site_admin)
      true
    elsif user.is_a?(GuestUser)
      true
    elsif user.end_user? && rollout_to_end_user?(user.demo_id)
      true
    else
      false
    end
  end

  ORGS_TO_ROLL_OUT_END_USER_SEARCH = ["Airbo"]
  def rollout_to_end_user?(demo_id)
    Demo.select(:id).joins(:organization).where(organization: { name: ORGS_TO_ROLL_OUT_END_USER_SEARCH }).pluck(:id).include?(demo_id)
  end

  protected

  def muted_followup_boards
    return if is_not_user?
    current_user.muted_followup_boards
  end

  def muted_digest_boards
    return if is_not_user?
    current_user.muted_digest_boards
  end

  def put_divider_between_sections?
    boards_as_admin.present? && boards_as_regular_user.present?
  end

  def is_user?
    current_user && current_user.is_a?(User)
  end

  def is_not_user?
    !is_user?
  end

  def show_save_progress_button
    current_user.try(:is_guest?)
  end
end
