class Goal < ActiveRecord::Base
  include DemoScope

  include DemoScope
  has_many :rules
  has_many :acts, :through => :rules

  belongs_to :demo

  validates_presence_of :name, :demo_id

  def distinct_rules_toward_goal_count(user)
    self.acts.where(:user_id => user.id).map(&:rule_id).uniq.count  
  end

  def complete?(user)
    distinct_rules_toward_goal_count(user) == rules.count
  end

  def progress_text(user)
    "#{distinct_rules_toward_goal_count(user)}/#{self.rules.count} #{name}"
  end
end
