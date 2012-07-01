require 'special_command_handlers/base'

# Base class for AcceptFollowerHandler and IgnoreFollowerHandler

class SpecialCommandHandlers::FollowerHandler < SpecialCommandHandlers::Base
  def handle_command
    request_index = @args.first

    friendship = Friendship.pending(@user, request_index).first

    unless friendship
      return parsing_error_message(@user.bad_friendship_index_error_message(request_index))
    end

    act_on_friendship(friendship)
  end
end
