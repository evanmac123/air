module FollowHelper
  def follow_button(user, scope)
    form_tag user_friendship_path(user) do
      image_with_hover_submit_tag "new_activity/btn_beafan.png", "#{scope} .be-a-fan", :class => "be-a-fan", :disabled => user.demo.game_over?
    end
  end

  def unfollow_button(user, scope)
    form_tag user_friendship_path(user), :method => :delete do
      image_with_hover_submit_tag "new_activity/btn_defan.png", "#{scope} .defan", :class => "defan", :disabled => user.demo.game_over?
    end
  end

  protected

  def disabled_hash(user)
    user.demo.game_over? ? ({:disabled => true}) : ({})
  end
end
