class SuggestedTask < ActiveRecord::Base
  belongs_to :demo
  has_many :prerequisites
  has_many :prerequisite_tasks, :class_name => "SuggestedTask", :through => :prerequisites
  has_many :rule_triggers, :class_name => "Trigger::RuleTrigger"
  has_one :survey_trigger, :class_name => "Trigger::SurveyTrigger"
  has_one :demographic_trigger, :class_name => 'Trigger::DemographicTrigger'

  after_create do
    schedule_suggestion
  end

  has_alphabetical_column :name

  def suggest_to_user(user)
    TaskSuggestion.create!(:user => user, :suggested_task => self)
  end

  def due?
    start_time.nil? || start_time < Time.now
  end

  def has_demographic_trigger?
    self.demographic_trigger.present?
  end

  def only_manually_triggerable?
    self.rule_triggers.empty? && self.survey_trigger.blank? && !self.has_demographic_trigger?
  end

  def self.first_level
    joins("LEFT JOIN prerequisites ON suggested_tasks.id = prerequisites.suggested_task_id").where("prerequisites.id IS NULL")
  end

  def self.after_start_time
    where("start_time < ? OR start_time IS NULL", Time.now)
  end

  def self.bulk_complete(demo_id, suggested_task_id, emails)
    completion_states = {}
    %w(completed unknown already_completed in_different_game not_assigned).each {|bucket| completion_states[bucket.to_sym] = []}

    emails.each do |email|
      user = User.where(:email => email).first

      unless user
        completion_states[:unknown] << email
        next
      end

      unless user.demo_id == demo_id.to_i
        completion_states[:in_different_game] << email
        next
      end

      suggestion = user.task_suggestions.where(:suggested_task_id => suggested_task_id).first
      
      unless suggestion 
        completion_states[:not_assigned] << email
        next
      end
      
      if suggestion.satisfied
        completion_states[:already_completed] << email
        next
      end

      completion_states[:completed] << email
      suggestion.satisfy!
    end

    BulkCompleteMailer.report(completion_states).deliver!
  end

  protected

  def schedule_suggestion
    self.delay(:run_at => self.start_time).suggest_to_eligible_users
  end

  def suggest_to_eligible_users
    self.demo.users.each {|user| suggest_to_user(user) if user.satisfies_all_prerequisites(self)}
  end
end
