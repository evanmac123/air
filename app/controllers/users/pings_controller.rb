class Users::PingsController < ApplicationController
  include TrackEvent

  skip_before_filter :authorize
  before_filter :allow_guest_user

  def create
    params[:public_slug] = nil if params[:public_slug].empty?
    authorize

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

  def find_current_board
    if params[:public_slug]
      Demo.public_board_by_public_slug(params[:public_slug])
    elsif current_user
      current_user.demo
    end
  end
end
