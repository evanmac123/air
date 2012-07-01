require 'special_command_handlers/base'

class SpecialCommandHandlers::IgnoreFollowerHandler < SpecialCommandHandlers::FollowerHandler
  def act_on_friendship(friendship_to_ignore)
    friendship_to_ignore.ignore
  end
end
