class PublicBoardsController < ApplicationController
  skip_before_filter :authorize
  before_filter :allow_guest_user

  def show
    demo = Demo.find_by_public_slug(params[:public_slug])
    login_as_guest(demo) unless current_user
    redirect_to activity_path
  end

  protected

  def login_as_guest(demo)
    session[:guest_user] = {demo_id: demo.id}
  end
end
