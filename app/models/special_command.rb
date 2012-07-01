module SpecialCommand
  extend ParsingMessage

  def self.parse(user_or_phone, text, options)
    set_return_message_type!(options)

    user = user_or_phone.kind_of?(User) ?
             user_or_phone :
             User.find_by_phone_number(user_or_phone)
    return nil unless user

    normalized_command = text.strip.downcase.gsub(/\s+/, ' ')
    command_name, *args = normalized_command.split

    # Note that these are duplicated in User.sms_slug_does_not_match_commands,
    # So if you change something here, be sure to add it there too
    case command_name
    when 'follow', 'connect', 'fan', 'friend', 'befriend'
      SpecialCommandHandlers::FollowHandler.new(user, command_name, args, options, @return_message_type).handle_command 
    when 'myid'
      SpecialCommandHandlers::MyIdHandler.new(user, command_name, args, options, @return_message_type).handle_command
    when 'moreinfo', 'more'
      SpecialCommandHandlers::MoreInfoHandler.new(user, command_name, args, options, @return_message_type).handle_command
    when 's', 'suggest'
      SpecialCommandHandlers::SuggestionHandler.new(user, command_name, args, options, @return_message_type).handle_command
    when Survey::SURVEY_ANSWER_PATTERN
      SpecialCommandHandlers::SurveyResponseHandler.new(user, command_name, args, options, @return_message_type).handle_command
    when /^[a-z]$/
      SpecialCommandHandlers::UseSuggestedItemHandler.new(user, command_name, args, options, @return_message_type).handle_command
    when 'lastquestion'
      SpecialCommandHandlers::LastQuestionReminderHandler.new(user, command_name, args, options, @return_message_type).handle_command
    when 'rankings', 'ranking', 'standing', 'standings'
      SpecialCommandHandlers::FirstRankingsPageHandler.new(user, command_name, args, options, @return_message_type).handle_command
    when 'morerankings'
      SpecialCommandHandlers::NextRankingsPageHandler.new(user, command_name, args, options, @return_message_type).handle_command
    when 'help'
      SpecialCommandHandlers::HelpHandler.new(user, command_name, args, options, @return_message_type).handle_command
    when 'support'
      SpecialCommandHandlers::SupportHandler.new(user, command_name, args, options, @return_message_type).handle_command
    when 'survey', 'ur2cents', '2ur2cents'
      SpecialCommandHandlers::SurveyHandler.new(user, command_name, args, options, @return_message_type).handle_command
    when 'yes'
      SpecialCommandHandlers::AcceptFollowerHandler.new(user, command_name, args, options, @return_message_type).handle_command
    when 'no'
      SpecialCommandHandlers::IgnoreFollowerHandler.new(user, command_name, args, options, @return_message_type).handle_command
    when 'prizes'
      SpecialCommandHandlers::PrizeHandler.new(user, command_name, args, options, @return_message_type).handle_command
    when 'rules', 'commands'
      SpecialCommandHandlers::RulesHandler.new(user, command_name, args, options, @return_message_type).handle_command
    when 'mute'
      SpecialCommandHandlers::MuteHandler.new(user, command_name, args, options, @return_message_type).handle_command
    when 'gotit', 'got'
      SpecialCommandHandlers::SuppressMuteNoticeHandler.new(user, command_name, args, options, @return_message_type).handle_command
    else
      SpecialCommandHandlers::CreditGameReferrerHandler.new(user, command_name, args, options, @return_message_type).handle_command
    end
  end
end
