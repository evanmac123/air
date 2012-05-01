class Characteristic::BooleanType < Characteristic::BaseType
  def self.allowed_operators
    User::SegmentationOperator::DISCRETE_OPERATORS
  end
end
