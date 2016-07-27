# Fake "characteristics" for things like points, accepted_invitation_at,
# etc. They implement most of the same methods as Characteristic, but aren't
# backed by the DB.
#
# We create these so that we have a nice, uniform interface for
# displaying and querying on characteristics, without these things
# cluttering up a ton of code with special cases.

class DummyCharacteristic
  include CharacteristicBehavior

  IMPLEMENTATIONS = []

  attr_reader :id, :name, :datatype

  def self.find_by_dummy_id(id)
    self.all.detect{|instance| instance.id == id}
  end

  def self.all(options = {})
    IMPLEMENTATIONS.map{|implementation| implementation.new(options)}
  end
end

[
  ['points',                    'Points',           'Number'],
  ['date_of_birth',             'Date of birth',    'Date'],
  ['accepted_invitation_at',    'Joined at',        'Time'],
  ['gender',                    'Gender',           'Discrete'],
  ['claimed',                   'Joined?',          'Boolean'],
  ['has_phone_number',          'Has phone number', 'Boolean'],
  ['last_acted_at',             'Last acted at',    'Time']
].each do |field_id, human_name, datatype_short_name|
  class_name = field_id.camelize + "DummyCharacteristic"
  datatype_name = "Characteristic::" + datatype_short_name + "Type"

  eval <<-END_CLASS_DEF
    class #{class_name} < DummyCharacteristic
      def initialize(options = {})
        @id = '#{field_id}'
        @name = '#{human_name}'
        @datatype = #{datatype_name}
      end

      DummyCharacteristic::IMPLEMENTATIONS << self
    end
  END_CLASS_DEF
end

# For discrete dummy characteristics, we've also got to define allowed values.

class GenderDummyCharacteristic
  def allowed_values
    User::GENDERS
  end
end

# This dummy characteristic works a little differently, we need to set it up
# manually.

class LocationDummyCharacteristic < DummyCharacteristic
  def initialize(options = {})
    @id = 'location_id'
    @name = 'Location'
    @datatype = Characteristic::DiscreteType

    @demo_id = options[:demo_id]
  end

  def allowed_values
    locations.map {|location| location_and_demo_name(location) }
  end

  def cast_value(value)
    # Value comes in like "LocationName (DemoName)"
    value =~ /^(.*) \((.*?)\)$/
    location_name, demo_name = [$1, $2]
    Demo.find_by_name(demo_name).locations.find_by_name(location_name).id
  end

  protected

  def locations
    @_locations ||= if (@demo_id)
                      Demo.find(@demo_id).locations
                    else
                      Location.all
                    end

    @_locations
  end

  def location_and_demo_name(location)
    "#{location.name} (#{location.demo.name})"
  end

  DummyCharacteristic::IMPLEMENTATIONS << self
end
