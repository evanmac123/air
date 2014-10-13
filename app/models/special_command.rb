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

    handler_class = self.determine_handler_for_command(command_name)
    handler_class.new(user, command_name, args, options, @return_message_type).handle_command 
  end

  @@reserved_words ||= []

  def self.reserved_words
    @@reserved_words
  end

  def self.is_reserved_word?(word)
    @@reserved_words.include?(word)
  end

  protected

  @@registered_handlers ||= ActiveSupport::OrderedHash.new
  @@default_handler ||= SpecialCommandHandlers::NullHandler

  def self.determine_handler_for_command(command_name)
    matching_pair = @@registered_handlers.detect do |command_list, handler_class| 
      command_list.any?{ |candidate_command| candidate_command === command_name}
    end

    if matching_pair
      matching_pair.last
    else
      @@default_handler
    end
  end

  def self.register_command_handler(command_list, handler_class)
    @@registered_handlers[command_list] = handler_class
    @@reserved_words += command_list.select{|command| command.kind_of?(String)}
  end

  def self.register_default_command_handler(handler_class)
    @@default_handler = handler_class
  end

  register_command_handler %w(stop),                                SpecialCommandHandlers::StopHandler
  register_command_handler %w(follow connect fan friend befriend),  SpecialCommandHandlers::FollowHandler
  register_command_handler %w(myid),                                SpecialCommandHandlers::MyIdHandler
  register_command_handler %w(info),                                SpecialCommandHandlers::MoreInfoHandler
  register_command_handler %w(s suggest),                           SpecialCommandHandlers::SuggestionHandler
  register_command_handler %w(help),                                SpecialCommandHandlers::HelpHandler
  register_command_handler %w(support),                             SpecialCommandHandlers::SupportHandler
  register_command_handler %w(prizes),                              SpecialCommandHandlers::PrizeHandler
  register_command_handler %w(rules commands),                      SpecialCommandHandlers::RulesHandler
  register_command_handler %w(mute),                                SpecialCommandHandlers::MuteHandler
  register_command_handler %w(ok),                                  SpecialCommandHandlers::SuppressMuteNoticeHandler

  register_default_command_handler SpecialCommandHandlers::CreditGameReferrerHandler
end
