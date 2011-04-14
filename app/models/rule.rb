class Rule < ActiveRecord::Base
  has_many   :acts

  validates_presence_of   :value
  validates_uniqueness_of :value

  before_save :normalize_value

  def to_s
    description || value
  end

  def user_hit_limit?(user)
    return false unless self.alltime_limit

    self.acts.where(:user_id => user.id).count >= self.alltime_limit
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

  def normalize_value
    self.value = self.value.strip.downcase.gsub(/\s+/, ' ')
  end
end
