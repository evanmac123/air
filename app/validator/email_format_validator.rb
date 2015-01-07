class EmailFormatValidator < ActiveModel::Validator
  VALID_EMAIL_FORMAT = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i.freeze

  def validate(record)
    field = options[:field] || :email
    value = record[field] 

    return if options[:allow_blank] && value.blank?

    unless value =~ VALID_EMAIL_FORMAT
      record.errors.add field, "is invalid"
    end
  end
end
