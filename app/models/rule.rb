class Rule < ActiveRecord::Base
  belongs_to :demo
  belongs_to :goal

  has_many   :acts
  has_one    :primary_value, :class_name => "RuleValue", :conditions => {:is_primary => true}
  has_many   :secondary_values, :class_name => "RuleValue", :conditions => {:is_primary => false}
  has_many   :rule_values

  def to_s
    description || self.primary_value.try(:value) || self.rule_values.oldest.first.value
  end

  def user_hit_limit?(user)
    return false unless self.alltime_limit

    self.acts.where(:user_id => user.id).count >= self.alltime_limit
  end

  # Convenience methods to set the primary and secondary values from a string
  # or array of strings, respectively.

  def set_primary_value!(new_value)
    value = self.primary_value || self.rule_values.build(:is_primary => true)
    value.value = new_value
    unless value.save 
      self.errors.add(:base, "Problem with primary value: #{value.errors.full_messages}")
      return false
    end

    true
  end

  def set_secondary_values!(new_values)
    _new_values = new_values.reject(&:blank?)
    self.secondary_values.where(["value NOT IN (?)", _new_values]).delete_all
    existing_values = self.secondary_values.map(&:value)
    (_new_values - existing_values).each do |new_value| 
      value = self.secondary_values.build(:value => new_value)
      unless value.save 
        self.errors.add(:base, "Problem with secondary value #{new_value}: #{value.errors.full_messages}") 
        return false
      end
    end

    true
  end

  def update_with_rule_values(new_attributes, primary_value, secondary_values=[])
    self.attributes = new_attributes

    Rule.transaction do
      self.save || (return false)

      self.set_primary_value!(primary_value) || (return false)
      self.set_secondary_values!(secondary_values) || (return false)
    end

    true
  end

  def self.create_with_rule_values(new_attributes, demo_id, primary_value, secondary_values)
    rule = Rule.new(:demo_id => demo_id)
    rule.update_with_rule_values(new_attributes, primary_value, secondary_values)
    rule
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
end
