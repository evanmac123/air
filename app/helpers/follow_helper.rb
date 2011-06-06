module FollowHelper
  def follow(user)
    button_to "Be a fan", user_friendship_path(user)
  end

  def unfollow(user)
    button_to "De-fan", user_friendship_path(user), :method => :delete
  end
end
