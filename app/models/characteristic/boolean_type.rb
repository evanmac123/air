class Characteristic::BooleanType < Characteristic::BaseType
  def self.format_value(value)
    if cast_value(value)
      'true'
    else
      'false'
    end
  end

  def self.cast_value(value)
    return value if value == true || value == false

    value.to_i != 0
  end

  def self.input_type
    :checkbox
  end

  def self.allowed_operators
    User::SegmentationOperator::DISCRETE_OPERATORS
  end
end
