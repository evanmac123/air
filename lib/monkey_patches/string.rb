class String
  LOWERCASE_RANGE = ('a'..'z').freeze

  def remove_mid_word_characters
    gsub(/'/, '')
  end

  def remove_non_words
    gsub(/[\W]/, '')
  end

  # Escape characters with special meanings in Postgres' LIKE and ILIKE
  # operators.
  def like_escape
    gsub(/%/, "\\%").gsub(/_/, "\\_")
  end

  def first_digit
    digit = split(/(\d)/)[1]
    if digit
      digit.to_i
    else
      0
    end
  end

  def as_pretty_phone
    return "" if self.blank?

    without_country_code = self.gsub(/^\+1/, '')
    area_code = without_country_code[0,3]
    exchange = without_country_code[3,3]
    rest = without_country_code[6,4]

    "(#{area_code}) #{exchange}-#{rest}"
  end

  def dummy_phone_number?
    self.match(/^\+1999/)
  end

  def is_email_address?
    return nil if self.include? ".."
    self.strip =~ /^[A-Z0-9_.\-+%]+@([A-Z0-9.\-]+\.[A-Z]{2,4})$/i
  end

  def email_domain
    return nil unless self.is_email_address?
    self =~ /@([^@]+)$/
    $1
  end

  def starts_with_lowercase?
    LOWERCASE_RANGE.include? self.first
  end
end
