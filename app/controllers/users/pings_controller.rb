class Users::PingsController < ApplicationController
  include TrackEvent
  include LoginByExploreToken

  prepend_before_filter :allow_guest_user
  before_filter :authorize_by_explore_token

  def create
    page_name = params[:page_name]
    event = params[:event]
    properties = params[:properties] || {}

    if page_name
      current_user.ping_page(page_name)
    elsif event
      current_user.ping(event, properties)
    else
      raise "No page name, no event given for mixpanel ping"
    end
    render nothing: true
  end

  protected

  def find_current_board
    if params[:public_slug]
      Demo.public_board_by_public_slug(params[:public_slug])
    elsif current_user
      current_user.demo
    end
  end
end
