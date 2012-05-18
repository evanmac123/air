class Characteristic::BaseType
  def self.format_value(value)
    value.to_s
  end

  def self.cast_value(value)
    value
  end

  # When rendering a form that allows an admin to change a characteristic of
  # this type, what input element should be rendered?
  def self.input_type
    :text
  end

  def self.ensure_operator_applicable(operator_class)
    raise User::NonApplicableSegmentationOperatorError unless allowed_operators.include?(operator_class)
  end

  def self.allowed_operator_names
    allowed_operators.map(&:human_name)
  end
end
