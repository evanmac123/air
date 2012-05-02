class Survey < ActiveRecord::Base
  has_many :survey_questions
  has_many :survey_valid_answers, :through => :survey_questions
  has_many :survey_prompts

  validates_presence_of :name, :open_at, :close_at

  validate :close_comes_after_open
  SURVEY_ANSWER_PATTERN = Regexp.new(/^[1-5]$/).freeze

  belongs_to :demo
  has_many   :survey_triggers, :class_name => "Trigger::SurveyTrigger"

  def all_answers_already_message
    "Thanks, we've got all of your survey answers already."      
  end

  def close_comes_after_open
    return unless open_at && close_at

    errors.add(:base, "Close time must be after open time") unless close_at > open_at
  end

  def latest_question_for(user)
    SurveyQuestion.unanswered_by(user, self).first
  end

  def self.open
    # Note: this is duplicated in User.open_survey
    self.where('? BETWEEN open_at AND close_at', Time.now)
  end
end
