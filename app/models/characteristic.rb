class Characteristic < ActiveRecord::Base
  include CharacteristicBehavior

  DATATYPE_NAMES_TO_CLASSES = ActiveSupport::OrderedHash.new
  # You're supposed to be able to do the following in one invocation of
  # OrderedHash#[] but I couldn't get it to work.
  [['Discrete', Characteristic::DiscreteType],
   ['Number', Characteristic::NumberType],
   ['Date', Characteristic::DateType],
   ['Time', Characteristic::TimeType],
   ['Boolean', Characteristic::BooleanType]
  ].each do |name, klass|
    DATATYPE_NAMES_TO_CLASSES[name] = klass
  end
  DATATYPE_NAMES_TO_CLASSES.freeze

  DATATYPE_CLASSES_TO_NAMES = DATATYPE_NAMES_TO_CLASSES.invert.freeze

  belongs_to :demo

  validates_uniqueness_of :name

  serialize :allowed_values, Array
  serialize :datatype

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

  def value_allowed?(value)
    return true unless respect_allowed_values?
    allowed_values.include?(value)
  end

  def self.find_with_dummy_characteristic_ids(id)
    if id.kind_of?(String) && id !~ /^\d+$/
      DummyCharacteristic.find_by_dummy_id(id)
    else
      find_without_dummy_characteristic_ids(id)
    end
  end

  class << self
    alias_method_chain :find, :dummy_characteristic_ids
  end

  def self.datatype_names
    DATATYPE_NAMES_TO_CLASSES.keys
  end

  def self.agnostic
    where(demo_id: nil)
  end

  def self.generic
    where(demo_id: nil)
  end

  def self.in_demo(demo)
    where(demo_id: demo.id)
  end

  def self.visible_from_demo(demo)
    dummy_characteristics = DummyCharacteristic.all(demo_id: demo.id)
    generic_characteristics = Characteristic.generic
    demo_specific_characteristics = Characteristic.in_demo(demo)

    [dummy_characteristics, generic_characteristics, demo_specific_characteristics]
  end
end
