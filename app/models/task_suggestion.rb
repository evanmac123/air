class TaskSuggestion < ActiveRecord::Base
  belongs_to :user
  belongs_to :suggested_task

  after_update do
    check_for_new_available_tasks if changed.include?('satisfied')
  end

  def satisfy!
    update_attributes(:satisfied => true)
    a = Act.new(:user_id =>self.user_id, :inherent_points => self.suggested_task.bonus_points)
    a.save
  end

  def self.for_task(task)
    where(:suggested_task_id => task.id)
  end

  def self.satisfied
    where(:satisfied => true)
  end

  def self.unsatisfied
    where(:satisfied => false)
  end

  def self.satisfiable_by_rule(rule_or_rule_id)
    satisfiable(rule_or_rule_id, Rule, "trigger_rule_triggers", "rule_id")
  end

  def self.satisfiable_by_survey(survey_or_survey_id)
    satisfiable(survey_or_survey_id, Survey, "trigger_survey_triggers", "survey_id")
  end

  def self.without_mandatory_referrer
    # Assumes we've already joined to RuleTrigger
    where("trigger_rule_triggers.referrer_required" => false)
  end

  protected

  def check_for_new_available_tasks
    potentially_available_tasks = Prerequisite.where(:prerequisite_task_id => self.suggested_task.id).map(&:suggested_task).uniq

    potentially_available_tasks.each do |potentially_available_task|
      if self.user.satisfies_all_prerequisites(potentially_available_task) && potentially_available_task.due?
        potentially_available_task.suggest_to_user(self.user)
      end
    end
  end

  def self.satisfiable(satisfying_object_or_id, satisfying_object_class, trigger_table_name, satisfying_object_column)
    satisfying_object_id = triggering_object_id(satisfying_object_or_id, satisfying_object_class)
    unsatisfied.joins(:suggested_task).joins("INNER JOIN #{trigger_table_name} ON #{trigger_table_name}.suggested_task_id = suggested_tasks.id").where("#{trigger_table_name}.#{satisfying_object_column} = ?", satisfying_object_id)
  end

  def self.triggering_object_id(object_or_object_id, expected_class)
    object_or_object_id.kind_of?(expected_class) ? object_or_object_id.id : object_or_object_id
  end
end
