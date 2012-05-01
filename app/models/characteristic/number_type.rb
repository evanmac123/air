class Characteristic::NumberType < Characteristic::BaseType
  def self.allowed_operators
    User::SegmentationOperator::ALL_OPERATORS
  end
end
