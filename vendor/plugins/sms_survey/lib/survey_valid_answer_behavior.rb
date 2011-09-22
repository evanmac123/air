module SmsSurvey
  module SurveyValidAnswerBehavior
    extend ActiveSupport::Concern

    included do
      belongs_to :survey_question
      has_one :survey, :through => :survey_question

      validates_presence_of :survey_question_id
      validates_presence_of :value
      validates_uniqueness_of :value, :scope => :survey_question_id
    end
  end
end
