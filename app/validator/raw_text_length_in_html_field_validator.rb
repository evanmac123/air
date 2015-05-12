class RawTextLengthInHTMLFieldValidator < ActiveModel::Validator
  def validate(record)
    field, maximum, message = options.values_at(:field, :maximum, :message)
    value = record[field]

    sanitized_value = Sanitize.fragment(value).
                               gsub(/(\u00A0)+/, ''). # remove all non-breaking spaces 
                                                      # that Sanitize may leave after removed tags
                               gsub(/\s+/, ' ').
                               strip
    if sanitized_value.length > maximum
      record.errors.add field, message
    end
  end
end