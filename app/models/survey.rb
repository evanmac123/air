class Survey < ActiveRecord::Base
  include SmsSurvey::SurveyBehavior
end
