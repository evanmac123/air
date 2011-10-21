class Goal < ActiveRecord::Base
  has_many :rules
  has_many :acts, :through => :rules

  belongs_to :demo

  validates_presence_of :name, :demo_id

  def progress_text(user)
    distinct_rules_toward_goal_count = self.acts.where(:user_id => user.id).map(&:rule_id).uniq.count
    total_rule_count = self.rules.count

    "#{distinct_rules_toward_goal_count}/#{total_rule_count} #{name}"
  end
end
