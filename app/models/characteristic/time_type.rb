class Characteristic::TimeType < Characteristic::BaseType
  def self.allowed_operators
    User::SegmentationOperator::CONTINUOUS_OPERATORS
  end

  def self.cast_value(value)
    return nil unless value.present?
    Chronic.parse(value)
  end

  def self.format_value(value)
    if value.respond_to? :strftime
      value.strftime("%B %-d, %Y, %I:%M %p") # example: "January 1, 2012, 07:00 PM"
    else
      value
    end
  end
end
