class Characteristic::NumberType < Characteristic::BaseType
  def self.cast_value(value)
    value.to_f
  end

  def self.allowed_operators
    User::SegmentationOperator::ALL_OPERATORS
  end
end
