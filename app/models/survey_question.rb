class SurveyQuestion < ActiveRecord::Base
  include SmsSurvey::SurveyQuestionBehavior
end
