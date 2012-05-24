# Fake "characteristics" for things like points, accepted_invitation_at,
# etc. They implement most of the same methods as Characteristic, but aren't
# backed by the DB.
#
# We create these so that we have a nice, uniform interface for
# displaying and querying on characteristics, without these things 
# cluttering up a ton of code with special cases.

class DummyCharacteristic
  include CharacteristicBehavior
  include Singleton

  IMPLEMENTATIONS = []

  attr_reader :id, :name, :datatype

  def self.find_by_dummy_id(id)
    self.all.detect{|instance| instance.id == id}
  end

  def self.all
    IMPLEMENTATIONS.map(&:instance)
  end
end

[
  ['points',                 'Number'],
  ['date_of_birth',          'Date'],
  ['accepted_invitation_at', 'Time'],
  ['height',                 'Number'],
  ['weight',                 'Number'],
  ['gender',                 'Discrete']
].each do |field_id, datatype_short_name|
  name = field_id.humanize
  class_name = field_id.camelize + "DummyCharacteristic"
  datatype_name = "Characteristic::" + datatype_short_name + "Type"

  eval <<-END_CLASS_DEF
    class #{class_name} < DummyCharacteristic
      def initialize
        @id = '#{field_id}'
        @name = '#{name}'
        @datatype = #{datatype_name}
      end
    end

    DummyCharacteristic::IMPLEMENTATIONS << #{class_name}
  END_CLASS_DEF
end

# For discrete dummy characteristics, we've also got to define allowed values.

class GenderDummyCharacteristic < DummyCharacteristic
  def allowed_values
    User::GENDERS
  end
end
