class Users::PingsController < ApplicationController
  include TrackEvent

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
end
