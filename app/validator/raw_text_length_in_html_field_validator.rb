class RawTextLengthInHTMLFieldValidator < ActiveModel::Validator
  def validate(record)
    field, maximum, message = options.values_at(:field, :maximum, :message)
    value = record[field]
    raw_text = Nokogiri::HTML::Document.parse(value)
    
    if raw_text.length > maximum
      record.errors.add field, message
    end
  end
end
