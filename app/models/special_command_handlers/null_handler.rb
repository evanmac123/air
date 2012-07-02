require 'special_command_handlers/base'

# Dummy handler that does nothing, used as the default default command handler
class SpecialCommandHandlers::NullHandler < SpecialCommandHandlers::Base
  def handle_command
    nil
  end
end
