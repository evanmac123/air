class Characteristic::BooleanType < Characteristic::BaseType
  def self.format_value(value)
    if cast_value(value)
      'true'
    else
      'false'
    end
  end

  def self.cast_value(value)
    normalized_value = value.to_s.downcase

    # Truthy values
    return true if %w(yes y true t 1).include? normalized_value

    # Falsy values
    return false if %w(no n false f 0).include? normalized_value

    # We won't try to guess, kthx
    nil
  end

  def self.input_type
    :checkbox
  end

  def self.allowed_operators
    User::SegmentationOperator::DISCRETE_OPERATORS
  end
end
