class Characteristic::BaseType
  def self.allowed_operator_names
    allowed_operators.map(&:human_name)
  end
end
