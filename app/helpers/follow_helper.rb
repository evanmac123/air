module FollowHelper
  def follow_button(user, button_to_options={})
    button_to "Be a fan", user_friendship_path(user), button_to_options.merge(disabled_hash(user))
  end

  def unfollow_button(user, button_to_options={})
    button_to "De-fan", user_friendship_path(user), button_to_options.merge(disabled_hash(user)).merge(:method => :delete)
  end

  protected

  def disabled_hash(user)
    user.demo.game_over? ? ({:disabled => true}) : ({})
  end
end
