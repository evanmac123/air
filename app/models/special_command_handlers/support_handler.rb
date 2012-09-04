require 'special_command_handlers/base'

class SpecialCommandHandlers::SupportHandler < SpecialCommandHandlers::Base
  def handle_command
    @user.send_support_request
    parsing_success_message(@user.demo.support_reply)
  end
end
