module AllowGuestUsers
  def current_user
    super || @potential_user || guest_user
  end

  def guest_user(demo = find_current_board)
    @cached_guest_user ||= GuestUser.find(session[:guest_user_id] ||= create_guest_user(demo).id)

    attach_board_to_guest_user if params[:public_slug]

    @cached_guest_user
  rescue ActiveRecord::RecordNotFound
    session[:guest_user_id] = nil
    guest_user
  end

  def create_guest_user(demo)
    u = GuestUser.create!(demo: demo)
    session[:guest_user_id] = u.id
    u
  end

  def attach_board_to_guest_user
    board = Demo.find_by_public_slug(params[:public_slug])
    if board && @cached_guest_user.demo_id != board.id
      @cached_guest_user.demo = board
      @cached_guest_user.save!
    end
  end

  def authenticate_as_potential_user
    return false unless session[:potential_user_id]
    @potential_user = PotentialUser.find_by_id(session[:potential_user_id])
  end
end
