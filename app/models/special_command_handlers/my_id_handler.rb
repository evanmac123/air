require 'special_command_handlers/base'

class SpecialCommandHandlers::MyIdHandler < SpecialCommandHandlers::Base
  def handle_command
    parsing_success_message("Your username is #{@user.sms_slug}.")
  end
end
