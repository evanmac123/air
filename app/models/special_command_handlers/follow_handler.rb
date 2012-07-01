require 'special_command_handlers/base'

class SpecialCommandHandlers::FollowHandler < SpecialCommandHandlers::Base
  def handle_command
    sms_slug_to_follow = @args.first
    channel = @parsing_options[:channel]

    user_to_follow = User.claimed.where(:sms_slug => sms_slug_to_follow, :demo_id => @user.demo_id).first

    return parsing_error_message("Sorry, we couldn't find a user with the username #{sms_slug_to_follow}.") unless user_to_follow

    return parsing_error_message("Sorry, you can't add yourself as a friend.") if @user.id == user_to_follow.id

    Friendship.transaction do
      return parsing_success_message("You've already asked to be friends with #{user_to_follow.name}.") if @user.initiated_friends.where('friendships.friend_id' => user_to_follow.id).present?

      return parsing_success_message("You're already friends with #{user_to_follow.name}.") if @user.accepted_friends.where('friendships.friend_id' => user_to_follow.id).present?

      return nil unless @user.befriend(user_to_follow, :channel => channel)
    end

    user_to_follow.follow_requested_message
  end

end
