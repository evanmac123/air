class ActiveModel::Errors
  def smarter_message(field_name)
    self[field_name].map do |error_message|
      if error_message.starts_with_lowercase?
        pretty_field_name = field_name.to_s.humanize
        "#{pretty_field_name} #{error_message}"
      else
        error_message
      end
    end
  end

  def smarter_full_messages
    self.keys.map{|field_name| smarter_message(field_name)}.flatten
  end
end
