class Rule < ActiveRecord::Base
  belongs_to :demo
  belongs_to :goal

  has_one    :primary_value, :class_name => "RuleValue", :conditions => {:is_primary => true}
  has_many   :secondary_values, :class_name => "RuleValue", :conditions => {:is_primary => false}
  has_many   :acts
  has_many   :rule_triggers, :dependent => :destroy, :class_name => "Trigger::RuleTrigger"
  has_many   :rule_values, :dependent => :destroy
  has_many   :labels
  has_many   :tags, :through => :labels
  belongs_to :primary_tag, :class_name => "Tag"
  def to_s
    description || self.primary_value.try(:value) || self.rule_values.oldest.first.value
  end

  def tags_with_primary
    if self.primary_tag
      [self.primary_tag] + self.tags
    else
      self.tags
    end
  end

  def tag_ids_with_primary
    if self.primary_tag_id
      [self.primary_tag_id] + self.tag_ids
    else
      self.tag_ids
    end
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

  # In some contexts we'd like to get the text of the primary value, but are
  # constrained to just passing a single symbol as a method name. Hence:
  def primary_value_text
    self.primary_value.value
  end
  
  def conflicts_with_with_sms_slugs
    conflicts = []
    self.rule_values.each do |rv|
      u = User.where(:sms_slug => rv.value.downcase, :demo_id => rv.rule.demo_id).first
      if u
        conflict_message = "Warning: rule value #{rv.value} conflicts with username of #{u.name} #{u.email}"
        conflicts << conflict_message
      end
    end
    return conflicts
  end

  def self.create_with_rule_values(new_attributes, demo_id, primary_value, secondary_values)
    rule = Rule.new(:demo_id => demo_id)
    rule.update_with_rule_values(new_attributes, primary_value, secondary_values)
    rule
  end

  def self.eligible_for_goal(goal)
    if goal.id
      where(["demo_id = ? AND (goal_id = ? OR goal_id IS NULL)", goal.demo.id, goal.id])
    else
      where(["demo_id = ? AND goal_id IS NULL", goal.demo.id])
    end
  end
end
