require 'special_command_handlers/base'

class SpecialCommandHandlers::SupportHandler < SpecialCommandHandlers::Base
  def handle_command
    @user.send_support_request
    parsing_success_message("Got it. We'll have someone email you shortly. Tech support is open 9 AM to 6 PM ET. If it's outside those hours, we'll follow-up first thing when we open.")
  end
end
