require 'special_command_handlers/base'

class SpecialCommandHandlers::AcceptFollowerHandler < SpecialCommandHandlers::FollowerHandler
  def act_on_friendship(friendship_to_accept)
    friendship_to_accept.accept
  end
end
