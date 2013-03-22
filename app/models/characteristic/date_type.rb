class Characteristic::DateType < Characteristic::BaseType
  def self.format_value(value)
    if value.respond_to? :strftime
      value.strftime("%B %-d, %Y") # example: "January 1, 2012"
    else
      value
    end
  end

  def self.cast_value(value)
    # We do #to_date to throw away the time portion of the time we get back
    # from Chronic.parse, but Mongo doesn't support Date fields yet. So we 
    # normalize it to a time in UTC, which is what Mongo wants, and then 
    # clamp it to midnight in an effort to make this halfway sane. Note that
    # Mongo will also choke on TimeWithZone.
    #
    # TL;DR: Dealing with times and dates is still disproportionately a pain
    # in the ass, and this works, so don't fuck with it.

    return nil unless value.present?
    Chronic.parse(value).to_date.to_time.utc.midnight
  end

  def self.allowed_operators
    User::SegmentationOperator::CONTINUOUS_OPERATORS
  end
end
