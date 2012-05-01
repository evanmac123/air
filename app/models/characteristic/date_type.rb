class Characteristic::DateType < Characteristic::BaseType
  def self.allowed_operators
    User::SegmentationOperator::ALL_OPERATORS
  end
end
