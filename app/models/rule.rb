class Rule < ActiveRecord::Base
  belongs_to :key

  validates_presence_of   :key_id, :if => :require_key?
  validates_presence_of   :value
  validates_uniqueness_of :value, :scope => :key_id

  def to_s
    description || "#{key.name} #{value}"
  end

  def self.positive(limit)
    where("points > 0").limit(limit)
  end

  def self.negative(limit)
    where("points < 0").limit(limit)
  end

  def self.neutral(limit)
    where("points = 0").limit(limit)
  end

  protected

  # This gives us an easy way to turn off key validation in the CodedRule
  # subclass.
  
  def require_key?
    true
  end
end
