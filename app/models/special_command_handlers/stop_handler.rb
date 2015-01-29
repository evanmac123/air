require 'special_command_handlers/base'

class SpecialCommandHandlers::StopHandler < SpecialCommandHandlers::Base
  def handle_command
    # We have this "help_command_explanation" interpolation because we want to
    # leave it out of email entirely, so we use channel_specific_translations
    # to stick it back into SMS and web replies.

    return nil unless @parsing_options[:channel] == :sms
    @user.update_column(:notification_method, 'email')
    msg = "Ok, you won't receive any more texts from us. To change your contact preferences, log into www.airbo.com and click Settings, or email support@airbo.com."
    parsing_success_message(msg)
  end
end
