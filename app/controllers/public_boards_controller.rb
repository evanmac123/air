class PublicBoardsController < ApplicationController
  skip_before_filter :authorize
  before_filter :allow_guest_user

  def show
    redirect_to public_activity_path(params[:public_slug])
  end

  protected

  def find_current_board
    Demo.public_board_by_public_slug(params[:public_slug])
  end
end
