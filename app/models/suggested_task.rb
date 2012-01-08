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

  protected

  def schedule_suggestion
    self.delay(:run_at => self.start_time).suggest_to_eligible_users
  end

  def suggest_to_eligible_users
    self.demo.users.each {|user| suggest_to_user(user) if user.satisfies_all_prerequisites(self)}
  end
end
