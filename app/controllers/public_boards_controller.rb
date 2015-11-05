class PublicBoardsController < ApplicationController
  include MixpanelHelper
  skip_before_filter :authorize
  before_filter :allow_guest_user

 #FIXME why have a separate resource that simply redirects to another
  #resource!!!!

  def show
    ping "Public Parent Board", {:url => request.url}, current_user
    redirect_to public_activity_path(params[:public_slug])
  end

  protected

  def find_current_board
    Demo.public_board_by_public_slug(params[:public_slug])
  end
end
