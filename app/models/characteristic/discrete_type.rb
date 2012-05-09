class Characteristic::DiscreteType < Characteristic::BaseType
  def self.cast_value(value)
    value
  end

  def self.input_type
    :select
  end

  def self.allowed_operators
    User::SegmentationOperator::DISCRETE_OPERATORS
  end
end
