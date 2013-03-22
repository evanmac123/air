class Characteristic::NumberType < Characteristic::BaseType
  def self.cast_value(value)
    return nil unless value.present?
    value.to_f
  end

  def self.allowed_operators
    User::SegmentationOperator::ALL_OPERATORS
  end
end
