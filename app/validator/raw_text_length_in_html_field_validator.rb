# frozen_string_literal: true

class RawTextLengthInHTMLFieldValidator < ActiveModel::Validator
  def validate(record)
    field, maximum, message = options.values_at(:field, :maximum, :message)
    value = record[field]
    raw_text = Nokogiri::HTML::Document.parse(value).text

    if (raw_text.length > maximum) && (record.status != Tile::PLAN)
      record.errors.add field, message
    end
  end
end
