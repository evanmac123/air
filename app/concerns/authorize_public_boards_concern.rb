module AuthorizePublicBoardsConcern
  def guest_user?
    guest_user if find_board_for_guest || single_tile_request
  end

  def find_board_for_guest
    @demo ||= Demo.public_board_by_public_slug(params[:public_slug])
  end

  def authorize!
    unless skip_authorize_for_public
      if params[:public_slug] && !current_user
        render 'shared/public_board_not_found', layout: 'external_marketing'
      else
        require_login
      end
    end
  end

  def skip_authorize_for_public
    current_user.is_a?(GuestUser) || current_user.is_a?(PotentialUser)
  end

  def single_tile_request
    params[:controller] == "tiles" && params[:action].in?(%w(show))
  end
end