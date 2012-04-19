class User::SegmentationOperatorError < StandardError; end
class User::UnknownSegmentationOperatorError < User::SegmentationOperatorError; end

class User::SegmentationOperator
  def self.characteristic(characteristic_id)
    "characteristics.#{characteristic_id}"
  end

  def self.find_by_name(operator_name)
    case operator_name.to_s
    when "equals"
      User::EqualsOperator
    when "not_equals"
      User::NotEqualsOperator
    else
      raise User::SegmentationOperatorError.new("Unrecognized operator name \"#{operator_name}\"")
    end
  end

  def self.add_criterion_to_query(query, characteristic_id, operator_name, *operands)
    _operands = operands.respond_to?(:flatten) ? operands.flatten : operands

    operator = self.find_by_name(operator_name)
    operator.add_criterion_to_query(query, characteristic_id, _operands)
  end

  def self.add_criterion_to_query!(query, characteristic_id, operator_name, *operands)
    query = self.add_criterion_to_query(query, characteristic_id, operator_name, operands)
  end
end

class User::EqualsOperator < User::SegmentationOperator
  def self.add_criterion_to_query(query, characteristic_id, operands)
    other = operands.first
    query.where(characteristic(characteristic_id) => other)
  end
end

class User::NotEqualsOperator < User::SegmentationOperator
  def self.add_criterion_to_query(query, characteristic_id, operands)
    other = operands.first
    query.where(characteristic(characteristic_id).to_sym.ne => other)
  end
end
