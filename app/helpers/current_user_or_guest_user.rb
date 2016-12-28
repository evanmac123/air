module CurrentUserOrGuestUser
  def current_user
    super || guest_user?
  end

  def guest_user?
    guest_user
  end
end
