module CurrentUserOrGuestUser
  def current_user
    super || guest_user
  end
end
