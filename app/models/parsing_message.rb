module ParsingMessage
  def parsing_error_message(message)
    parsing_message(message, :failure)
  end

  def parsing_success_message(message)
    parsing_message(message, :success)
  end

  def parsing_message(message, message_type)
    if @return_message_type
      [message, message_type]
    else
      message
    end
  end

  def set_return_message_type!(option_hash)
    @return_message_type = option_hash[:return_message_type]
  end
end
