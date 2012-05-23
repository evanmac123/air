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

  attr_reader :id, :name, :datatype

  def self.find_by_dummy_id(id)
    self.all.detect{|instance| instance.id == id}
  end

  def self.all
    [
      PointsDummyCharacteristic,
      DateOfBirthDummyCharacteristic,
      AcceptedInvitationAtDummyCharacteristic
    ].map(&:instance)
  end
end

class PointsDummyCharacteristic < DummyCharacteristic
  def initialize
    @id = 'points'
    @name = 'Points'
    @datatype = Characteristic::NumberType
  end
end

class DateOfBirthDummyCharacteristic < DummyCharacteristic
  def initialize
    @id = 'date_of_birth'
    @name = 'Date of birth'
    @datatype = Characteristic::DateType
  end
end

class AcceptedInvitationAtDummyCharacteristic < DummyCharacteristic
  def initialize
    @id = 'accepted_invitation_at'
    @name = 'Accepted invitation timestamp'
    @datatype = Characteristic::TimeType
  end
end
