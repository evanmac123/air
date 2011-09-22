module SmsSurvey
  module SurveyAnswerBehavior 
    extend ActiveSupport::Concern

    included do
      belongs_to :user
      belongs_to :survey_question
      belongs_to :survey_valid_answer
      has_one :survey, :through => :survey_question
    end
  end
end
