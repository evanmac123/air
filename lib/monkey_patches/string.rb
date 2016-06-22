class String
  # Note: you must restart the server for changes in this file to take effect
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

  def as_obfuscated_phone
   ph = as_pretty_phone
   ph.empty? ? ph : "(***)-***-#{ph[-4, 4]}"
  end

  def as_pretty_phone
    return "" if self.blank?

    without_country_code = self.gsub(/^\+1/, '')
    area_code = without_country_code[0,3]
    exchange = without_country_code[3,3]
    rest = without_country_code[6,4]
    output = "(#{area_code}) #{exchange}-#{rest}"
    if output == "(914) 380-3854"
      output.gsub!("3854", "FUJI (3854)")
    end
    output
  end

  def dummy_phone_number?
    self.match(/^\+1999/)
  end

  def is_email_address?
    return nil if self.include? ".."
    self.strip =~ /^[A-Z0-9_.\-+%]+@([A-Z0-9.\-]+\.[A-Z]{2,4})$/i
  end
  
  def is_not_email_address?
    is_email_address? ? false : true
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
