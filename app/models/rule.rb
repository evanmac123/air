class Rule < ActiveRecord::Base
  belongs_to :demo

  has_one    :primary_value,    :class_name => "RuleValue", :conditions => {:is_primary => true}
  has_many   :secondary_values, :class_name => "RuleValue", :conditions => {:is_primary => false}
  has_many   :rule_values, :dependent => :destroy

  has_many   :acts
  has_many   :rule_triggers, :dependent => :destroy, :class_name => "Trigger::RuleTrigger"
  has_many   :labels, :dependent => :destroy
  has_many   :tags, :through => :labels
  belongs_to :primary_tag, :class_name => "Tag"

  validates_length_of :reply, :maximum => 120

  validates :points, :with => :present_and_non_negative, :on => :client_admin

  before_destroy :nullify_acts
  
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

  def user_hit_daily_limit?(user)
    limiting_tags = tags.with_daily_limit.order("daily_limit ASC").to_a
    limiting_tags << primary_tag if (primary_tag && primary_tag.daily_limit)

    return false if limiting_tags.empty?

    limiting_tags.each do |limiting_tag|
      if user.acts.done_today.where(rule_id: limiting_tag.rule_ids + limiting_tag.rules_as_primary_tag_ids).count >= limiting_tag.daily_limit
        return true
      end
    end

    false
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
    return [] unless self.demo

    conflicts = []
    self.rule_values.each do |rule_value|
      user = self.demo.users.where(:sms_slug => rule_value.value.downcase).first
      if user
        conflict_message = "Warning: rule value #{rule_value.value} conflicts with username of #{user.name} #{user.email}"
        conflicts << conflict_message
      end
    end
    return conflicts
  end

  def present_and_non_negative
    if points.present?
      self.errors.add(:base, "points can't be negative") if points < 0
    else
      self.errors.add(:base, "points can't be blank") 
    end
  end

  def self.create_with_rule_values(new_attributes, demo_id, primary_value, secondary_values)
    rule = Rule.new(:demo_id => demo_id)
    unless rule.update_with_rule_values(new_attributes, primary_value, secondary_values)
      # Rather than leave this half-baked, trash it, but return it anyway so
      # we can use it to re-populate the form.
      rule.destroy
    end

    rule
  end

  private

  def nullify_acts
    acts.each { |act| act.update_attribute :rule_id, nil }
  end
end
