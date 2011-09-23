class Survey < ActiveRecord::Base
  include SmsSurvey::SurveyBehavior

  belongs_to :demo
end
