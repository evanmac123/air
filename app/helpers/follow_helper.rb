module FollowHelper
  def follow_button(user, scope)
    form_tag user_friendship_path(user) do
      image_with_hover_submit_tag fan_button_skinned, "#{scope} .be-a-fan", :class => "be-a-fan", :disabled => user.demo.game_closed?
    end
  end

  def unfollow_button(user, scope)
    form_tag user_friendship_path(user), :method => :delete do
      image_with_hover_submit_tag defan_button_skinned, "#{scope} .defan", :class => "defan", :disabled => user.demo.game_closed?
    end
  end
end
