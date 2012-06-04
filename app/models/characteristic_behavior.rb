module CharacteristicBehavior
  # Information about what sort of input field we should render for this
  # characteristic
  def input_specifier
    field_values = case datatype.input_type
                   when :select
                     allowed_values
                   else 
                     ''
                   end
    {
      field_type: datatype.input_type,
      allowed_values: field_values
    }
  end

  def allowed_operator_names
    self.datatype.allowed_operator_names
  end

  def cast_value(value)
    self.datatype.cast_value(value)
  end

  # How to display a value of this characteristic in an explanation
  def format_value(value)
    self.datatype.format_value(value)
  end

  def respect_allowed_values?
    self.datatype.respect_allowed_values?
  end
end
