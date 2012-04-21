class Task < ActiveRecord::Base
  belongs_to :demo
  has_many :prerequisites
  has_many :prerequisite_tasks, :class_name => "Task", :through => :prerequisites
  has_many :rule_triggers, :class_name => "Trigger::RuleTrigger"
  has_one :survey_trigger, :class_name => "Trigger::SurveyTrigger"
  has_one :demographic_trigger, :class_name => 'Trigger::DemographicTrigger'
  has_many :task_suggestions, :dependent => :destroy
  validates_uniqueness_of :identifier
  validates_presence_of :identifier, :message => "Please include an identifier"

  after_create do
    schedule_suggestion
  end

  has_alphabetical_column :name

  def suggest_to_user(user)
    TaskSuggestion.create!(:user => user, :task => self)
  end

  def due?
    return true if start_time.nil?
    if end_time
      return true if start_time < Time.now && (end_time > Time.now)
    else
      return true if start_time < Time.now
    end
  end

  def has_demographic_trigger?
    self.demographic_trigger.present?
  end

  def only_manually_triggerable?
    self.rule_triggers.empty? && self.survey_trigger.blank? && !self.has_demographic_trigger?
  end

  def self.first_level
    joins("LEFT JOIN prerequisites ON tasks.id = prerequisites.task_id").where("prerequisites.id IS NULL")
  end

  def self.after_start_time_and_before_end_time
    where("start_time < ? AND end_time > ? OR start_time IS NULL", Time.now, Time.now)
  end

  def self.bulk_complete(demo_id, task_id, emails)
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

      suggestion = user.task_suggestions.where(:task_id => task_id).first
      
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

    BulkCompleteMailer.delay.report(completion_states)
  end

  protected

  def schedule_suggestion
    self.delay(:run_at => self.start_time).suggest_to_eligible_users
  end

  def suggest_to_eligible_users
    self.demo.users.each do |user| 
      next if user.tasks.include?(self)
      suggest_to_user(user) if user.satisfies_all_prerequisites(self)
    end
  end
end
