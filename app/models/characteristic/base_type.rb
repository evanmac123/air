class Characteristic::BaseType
  def self.ensure_operator_applicable(operator_class)
    raise User::NonApplicableSegmentationOperatorError unless allowed_operators.include?(operator_class)
  end

  def self.allowed_operator_names
    allowed_operators.map(&:human_name)
  end
end
