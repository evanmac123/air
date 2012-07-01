module SpecialCommandHandlers
  class Base
    include ParsingMessage

    def initialize(user, command_name, args, parsing_options, return_message_type)
      @user = user
      @command_name = command_name
      @args = args
      @parsing_options = parsing_options
      @return_message_type = return_message_type
    end
  end
end
