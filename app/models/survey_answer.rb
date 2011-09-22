class SurveyAnswer < ActiveRecord::Base
  include SmsSurvey::SurveyAnswerBehavior
end
