module FollowHelper
  def follow(user)
    button_to "Connect", user_friendship_path(user)
  end

  def unfollow(user)
    button_to "Unconnect", user_friendship_path(user), :method => :delete
  end
end
