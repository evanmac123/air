class Users::PingsController < ApplicationController
  include TrackEvent
  include LoginByExploreToken

  skip_before_filter :authorize, only: [:create_universal_ping]
  before_filter :authorize_by_explore_token
  before_filter :allow_guest_user, only: [:create_universal_ping]

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
  #it works also for guest users
  def create_universal_ping
    params[:public_slug] = nil if params[:public_slug].empty?
    authorize
    if current_user
      create
    else
      render nothing: true
    end
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
