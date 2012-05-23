class Characteristic::TimeType < Characteristic::BaseType
  def self.allowed_operators
    User::SegmentationOperator::ALL_OPERATORS
  end

  def self.cast_value(value)
    Chronic.parse(value)
  end
end
