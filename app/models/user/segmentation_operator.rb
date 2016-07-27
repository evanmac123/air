class User::SegmentationOperatorError < StandardError; end
class User::UnknownSegmentationOperatorError < User::SegmentationOperatorError; end
class User::NonApplicableSegmentationOperatorError < User::SegmentationOperatorError; end

# Couple of forward declarations so we can refer to one class from within
# another.
class User::SegmentationOperator; end
class User::EqualsOperator < User::SegmentationOperator; end
class User::NotEqualsOperator < User::SegmentationOperator; end
class User::LessThanOperator < User::SegmentationOperator; end
class User::GreaterThanOperator < User::SegmentationOperator; end
class User::LessThanOrEqualOperator < User::SegmentationOperator; end
class User::GreaterThanOrEqualOperator < User::SegmentationOperator; end

class User::SegmentationOperator
  DISCRETE_OPERATORS = [User::EqualsOperator, User::NotEqualsOperator].freeze
  CONTINUOUS_OPERATORS = [User::LessThanOperator, User::GreaterThanOperator, User::LessThanOrEqualOperator, User::GreaterThanOrEqualOperator].freeze
  ALL_OPERATORS = (DISCRETE_OPERATORS + CONTINUOUS_OPERATORS).freeze

  CLASS_BY_NAME = ActiveSupport::OrderedHash.new
  [
    ["equals", User::EqualsOperator],
    ["does not equal", User::NotEqualsOperator],
    ["is less than", User::LessThanOperator],
    ["is greater than", User::GreaterThanOperator],
    ["is less than or equal to", User::LessThanOrEqualOperator],
    ["is greater than or equal to", User::GreaterThanOrEqualOperator]
  ].each {|k,v| CLASS_BY_NAME[k] = v }

  CLASS_BY_NAME.freeze
  NAME_BY_CLASS = CLASS_BY_NAME.invert.freeze

  def initialize(operands)
    @operands = operands
  end

  def mongo_characteristic_name(characteristic_id)
    if characteristic_id.to_s =~ /^\d+$/
      "characteristics.#{characteristic_id}"
    else
      characteristic_id
    end
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

  protected

  def simple_mongo_translation(query, characteristic_id, mongo_operator)
    other = @operands.first
    query.and(mongo_characteristic_name(characteristic_id).to_sym.send(mongo_operator) => other)
  end

  def ensure_applicable_to_characteristic(characteristic_id)
    Characteristic.find(characteristic_id).datatype.ensure_operator_applicable(self.class)
  end

  def self.has_simple_mongo_translation(mongo_operator)
    class_eval <<-END_CLASS_EVAL
      def add_criterion_to_query(query, characteristic_id)
        ensure_applicable_to_characteristic(characteristic_id)
        simple_mongo_translation(query, characteristic_id, :#{mongo_operator})
      end
    END_CLASS_EVAL
  end
end

class User::EqualsOperator < User::SegmentationOperator
  # This is a hack, since there's no explicit "eq" operator. But since the
  # operator is getting called on a symbol to start with,
  #
  #   where(:foo => :bar) == where(:foo.to_sym => :bar)
  has_simple_mongo_translation :to_sym
end

class User::NotEqualsOperator < User::SegmentationOperator
  has_simple_mongo_translation :ne
end

class User::LessThanOperator < User::SegmentationOperator
  has_simple_mongo_translation :lt
end

class User::GreaterThanOperator < User::SegmentationOperator
  has_simple_mongo_translation :gt
end

class User::LessThanOrEqualOperator < User::SegmentationOperator
  has_simple_mongo_translation :lte
end

class User::GreaterThanOrEqualOperator < User::SegmentationOperator
  has_simple_mongo_translation :gte
end
