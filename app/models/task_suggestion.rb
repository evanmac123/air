class TaskSuggestion < ActiveRecord::Base
  belongs_to :user
  belongs_to :suggested_task

  after_update do
    check_for_new_available_tasks if changed.include?('satisfied')
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

  protected

  def check_for_new_available_tasks
    potentially_available_tasks = Prerequisite.where(:prerequisite_task_id => self.suggested_task.id).map(&:suggested_task).uniq

    potentially_available_tasks.each do |potentially_available_task|
      if self.user.satisfies_all_prerequisites(potentially_available_task) && potentially_available_task.due?
        potentially_available_task.suggest_to_user(self.user)
      end
    end
  end
end
