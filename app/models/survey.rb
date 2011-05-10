class Survey < ActiveRecord::Base
  belongs_to :demo
  has_many :survey_questions
  has_many :survey_valid_answers, :through => :survey_questions

  validates_presence_of :name, :open_at, :close_at

  validate :close_comes_after_open

  def close_comes_after_open
    return unless open_at && close_at

    errors.add(:base, "Close time must be after open time") unless close_at > open_at
  end

  def latest_question_for(user)
    self.survey_questions.unanswered_by(user).first
  end

  def self.open
    time = Time.now
    self.where(['? BETWEEN open_at AND close_at', Time.now])
  end
end
