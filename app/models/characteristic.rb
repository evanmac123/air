class Characteristic < ActiveRecord::Base
  DATATYPE_NAMES_TO_CLASSES = ActiveSupport::OrderedHash.new
  # You're supposed to be able to do the following in one invocation of
  # OrderedHash#[] but I couldn't get it to work.
  [['Discrete', Characteristic::DiscreteType],
   ['Number', Characteristic::NumberType]
  ].each do |name, klass|
    DATATYPE_NAMES_TO_CLASSES[name] = klass
  end
  DATATYPE_NAMES_TO_CLASSES.freeze

  DATATYPE_CLASSES_TO_NAMES = DATATYPE_NAMES_TO_CLASSES.invert.freeze

  belongs_to :demo

  validates_uniqueness_of :name

  serialize :allowed_values, Array
  serialize :datatype, Class

  def datatype=(value)
    datatype_class = if value.kind_of?(Class)
                       value
                     else
                       DATATYPE_NAMES_TO_CLASSES[value]
                     end

    write_attribute(:datatype, datatype_class)
  end

  def datatype_name
    DATATYPE_CLASSES_TO_NAMES[self.datatype]
  end

  def cast_value(value)
    self.datatype.cast_value(value)
  end

  def allowed_operator_names
    self.datatype.allowed_operator_names
  end

  def value_allowed?(value)
    return true unless allowed_values
    allowed_values.include?(value)
  end

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

  # How to display a value of this characteristic in an explanation
  def format_value(value)
    self.datatype.format_value(value)
  end

  def self.datatype_names
    DATATYPE_NAMES_TO_CLASSES.keys
  end

  def self.agnostic
    where(:demo_id => nil)
  end

  def self.generic
    where(:demo_id => nil)
  end

  def self.in_demo(demo)
    where(:demo_id => demo.id)
  end
end
