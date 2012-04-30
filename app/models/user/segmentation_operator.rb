class User::SegmentationOperatorError < StandardError; end
class User::UnknownSegmentationOperatorError < User::SegmentationOperatorError; end

# Couple of forward declarations so we can refer to one class from within
# another.
class User::SegmentationOperator; end
class User::EqualsOperator < User::SegmentationOperator; end
class User::NotEqualsOperator < User::SegmentationOperator; end

class User::SegmentationOperator
  CLASS_BY_NAME = ActiveSupport::OrderedHash.new
  [
    ["equals", User::EqualsOperator],
    ["does not equal", User::NotEqualsOperator]
  ].each {|k,v| CLASS_BY_NAME[k] = v }

  CLASS_BY_NAME.freeze
  NAME_BY_CLASS = CLASS_BY_NAME.invert.freeze

  def initialize(operands)
    @operands = operands
  end

  def mongo_characteristic_name(characteristic_id)
    "characteristics.#{characteristic_id}"
  end

  def self.human_name
    NAME_BY_CLASS[self]
  end

  def self.find_by_name(operator_name)
    klass = CLASS_BY_NAME[operator_name.to_s]
    raise User::SegmentationOperatorError.new("Unrecognized operator name \"#{operator_name}\"") unless klass
    klass
  end

  def self.add_criterion_to_query(query, characteristic_id, operator_name, *operands)
    _operands = operands.respond_to?(:flatten) ? operands.flatten : operands

    operator = self.find_by_name(operator_name).new(_operands)
    operator.add_criterion_to_query(query, characteristic_id)
  end

  def self.add_criterion_to_query!(query, characteristic_id, operator_name, *operands)
    query = self.add_criterion_to_query(query, characteristic_id, operator_name, operands)
  end
end

class User::EqualsOperator < User::SegmentationOperator
  def add_criterion_to_query(query, characteristic_id)
    other = @operands.first
    query.where(mongo_characteristic_name(characteristic_id) => other)
  end
end

class User::NotEqualsOperator < User::SegmentationOperator
  def add_criterion_to_query(query, characteristic_id)
    other = @operands.first
    query.where(mongo_characteristic_name(characteristic_id).to_sym.ne => other)
  end
end
