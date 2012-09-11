class Tile < ActiveRecord::Base
  belongs_to :demo
  has_many :prerequisites
  has_many :prerequisite_tiles, :class_name => "Tile", :through => :prerequisites
  has_many :rule_triggers, :class_name => "Trigger::RuleTrigger"
  has_one :survey_trigger, :class_name => "Trigger::SurveyTrigger"
  has_one :demographic_trigger, :class_name => 'Trigger::DemographicTrigger'
  has_many :tile_completions, :dependent => :destroy
  validates_uniqueness_of :identifier
  validates_presence_of :identifier, :message => "Please include an identifier"
  attr_accessor :display_completion_on_this_request

  has_alphabetical_column :name
  extend Sequenceable

  def satisfy_for_user!(user, channel=nil)
    completion = TileCompletion.create!(:tile_id => id, :user_id => user.id)
    OutgoingMessage.send_side_message(user, completion.satisfaction_message, :channel => channel)
    Act.create!(:user_id =>user.id, :inherent_points => bonus_points, :text => "I completed a daily dose!")
  end

  def due?
    now = Time.now
    return false if start_time && (start_time > now)
    return false if end_time && (end_time < now)
    true
  end

  def has_demographic_trigger?
    self.demographic_trigger.present?
  end

  def only_manually_triggerable?
    self.rule_triggers.empty? && self.survey_trigger.blank? && !self.has_demographic_trigger?
  end

  def self.due_ids
    due_tile_ids = []
    find_each do |tile|
      due_tile_ids << tile.id if tile.due?
    end
    due_tile_ids
  end

  def self.displayable_to_user(user)
    satisfiable_tiles = satisfiable_to_user(user)
    recently_completed_ids = user.tile_completions.waiting_to_display_one_final_time.map(&:tile_id)
    recently_completed_tiles = Tile.where(id: recently_completed_ids)
    
    # Set the 'display_completion_on_this_request' flag if it was /just/ completed
    recently_completed_tiles = recently_completed_tiles.map do |tile|
      tile.display_completion_on_this_request = true
      tile
    end
    satisfiable_tiles + recently_completed_tiles
  end

  def self.satisfiable_by_rule_to_user(rule_or_rule_id, user)
    satisfiable_by_rule(rule_or_rule_id).satisfiable_to_user(user)
  end

  def self.satisfiable_by_survey_to_user(survey_or_survey_id, user)
    satisfiable_by_survey(survey_or_survey_id).satisfiable_to_user(user)
  end

  def self.satisfiable_by_demographics_to_user(user)
    satisfiable_by_demographics.satisfiable_to_user(user)
  end

  def self.satisfiable_to_user(user)
    tiles_due_in_demo = where(demo_id: user.demo.id, id: due_ids)
    ids_completed = user.tile_completions.satisfied.map(&:tile_id)
    satisfiable_tiles = tiles_due_in_demo.reject {|t| ids_completed.include? t.id}
    # Reject the ones whose prereqs have not been met
    satisfiable_tiles.reject! do |t|
      hide = false
      t.prerequisites.each do |p|
        unless ids_completed.include? p.prerequisite_tile_id
          hide = true
        end
      end
      hide
    end
    satisfiable_tiles
  end

  def self.first_level
    joins("LEFT JOIN prerequisites ON tiles.id = prerequisites.tile_id").where("prerequisites.id IS NULL")
  end

  def self.after_start_time_and_before_end_time
    where("start_time < ? AND end_time > ? OR start_time IS NULL", Time.now, Time.now)
  end

  def self.bulk_complete(demo_id, tile_id, emails)
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

      suggestion = user.tile_completions.where(:tile_id => tile_id).first
      
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

  def self.satisfiable_by_rule(rule_or_rule_id)
    satisfiable_by_object(rule_or_rule_id, Rule, "trigger_rule_triggers", "rule_id")
  end

  def self.satisfiable_by_survey(survey_or_survey_id)
    satisfiable_by_object(survey_or_survey_id, Survey, "trigger_survey_triggers", "survey_id")
  end

  def self.satisfiable_by_demographics
    satisfiable_by_trigger_table('trigger_demographic_triggers')
  end

  protected

  def self.satisfiable_by_trigger_table(trigger_table_name)
    joins("INNER JOIN #{trigger_table_name} ON #{trigger_table_name}.tile_id = tiles.id")
  end

  def self.satisfiable_by_object(satisfying_object_or_id, satisfying_object_class, trigger_table_name, satisfying_object_column)
    satisfying_object_id = triggering_object_id(satisfying_object_or_id, satisfying_object_class)
    satisfiable_by_trigger_table(trigger_table_name).where("#{trigger_table_name}.#{satisfying_object_column} = ?", satisfying_object_id)
  end

  def self.triggering_object_id(object_or_object_id, expected_class)
    object_or_object_id.kind_of?(expected_class) ? object_or_object_id.id : object_or_object_id
  end

end
