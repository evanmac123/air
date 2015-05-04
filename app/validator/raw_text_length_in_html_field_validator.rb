class RawTextLengthInHTMLFieldValidator < ActiveModel::Validator
  def validate(record)
    field, maximum, message = options.values_at(:field, :maximum, :message)
    value = record[field]

    if Sanitize.fragment(value).length > maximum
      record.errors.add field, message
    end
  end
end