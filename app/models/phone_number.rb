module PhoneNumber
  INTERNATIONAL_EXIT_CODE = "+"
  USA_COUNTRY_CODE        = "1"

  def self.normalize(number)
    only_digits      = number.gsub(/[^0-9]/, '')
    return "" if only_digits.blank?

    with_country_code = if only_digits.first == USA_COUNTRY_CODE
                          only_digits
                        else
                          "#{USA_COUNTRY_CODE}#{only_digits}"
                        end
    "#{INTERNATIONAL_EXIT_CODE}#{with_country_code}"
  end

  def self.is_valid_number?(number)
    self.normalize(number).length == 12
  end
end
