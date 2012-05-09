class Characteristic::DateType < Characteristic::BaseType
  def self.cast_value(value)
    Chronic.parse(value).to_date
  end

  def self.allowed_operators
    User::SegmentationOperator::ALL_OPERATORS
  end
end
