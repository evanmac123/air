module UsersHelper
  def user_avatar_path(user:)
    user.avatar.url
  end

  def user_profile_path(user:)
    user_path(user)
  end

  def user_is_guest?(user:)
    user.is_guest?
  end

  def current_user_is_user?(user:)
    user == current_user
  end

  def user_first_name(user:)
    user.first_name if user.is_a?(User)
  end
end
