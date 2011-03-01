module FollowHelper
  def follow(user)
    button_to "Follow", user_friendship_path(user), :remote => true
  end

  def unfollow(user)
    button_to "Unfollow", user_friendship_path(user), :method => :delete, :remote => true
  end
end
