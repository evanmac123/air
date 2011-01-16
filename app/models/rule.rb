class Rule < ActiveRecord::Base
  belongs_to :key

  validates_presence_of   :key_id, :value
  validates_uniqueness_of :value, :scope => :key_id

  def to_s
    "#{key.name} #{value}"
  end

  def self.positive(limit)
    where("points > 0").limit(limit)
  end

  def self.negative(limit)
    where("points < 0").limit(limit)
  end
end
