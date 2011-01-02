module PhoneNumber
  INTERNATIONAL_EXIT_CODE = "+"
  USA_COUNTRY_CODE        = "1"

  def self.normalize(number)
    only_numbers      = number.gsub(/[^0-9]/, '')
    with_country_code = if only_numbers.first == USA_COUNTRY_CODE
                          only_numbers
                        else
                          "#{USA_COUNTRY_CODE}#{only_numbers}"
                        end
    "#{INTERNATIONAL_EXIT_CODE}#{with_country_code}"
  end
end
