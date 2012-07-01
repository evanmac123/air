require 'special_command_handlers/base'

class SpecialCommandHandlers::HelpHandler < SpecialCommandHandlers::Base
  def handle_command
    parsing_success_message(@user.demo.help_response)
  end
end
