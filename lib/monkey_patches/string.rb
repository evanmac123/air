class String
  LOWERCASE_RANGE = ('a'..'z').freeze

  def remove_mid_word_characters
    gsub(/'/, '')
  end

  def replace_non_words_with_spaces
    gsub(/[\W]/, ' ')
  end

  def remove_non_words
    gsub(/[\W]/, '')
  end

  def replace_spaces_with_hyphens
    gsub(/\ +/, '-')
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

  def email_domain
    self =~ /@([^@]+)$/
    $1
  end

  def starts_with_lowercase?
    LOWERCASE_RANGE.include? self.first
  end
end
