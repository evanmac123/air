class Characteristic::DiscreteType < Characteristic::BaseType
  def self.allowed_operators
    [User::EqualsOperator, User::NotEqualsOperator]
  end
end
