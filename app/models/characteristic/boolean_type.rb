class Characteristic::BooleanType < Characteristic::BaseType
  def self.cast_value(value)
    value.to_i != 0
  end

  def self.input_type
    :checkbox
  end

  def self.allowed_operators
    User::SegmentationOperator::DISCRETE_OPERATORS
  end
end
