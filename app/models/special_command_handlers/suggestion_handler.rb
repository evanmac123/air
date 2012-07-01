require 'special_command_handlers/base'

class SpecialCommandHandlers::SuggestionHandler < SpecialCommandHandlers::Base
  def handle_command
    if @args.empty?
      @args = BadMessage.where(:phone_number => @user.phone_number).order('created_at DESC').limit(1).first.body.split
    end

    if User.find_by_sms_slug(@args.last)
      @args.pop
    end

    Suggestion.create!(:user => @user, :value => @args.join(' '))
    parsing_success_message("Thanks! We'll take your suggestion into consideration.")
  end
end
