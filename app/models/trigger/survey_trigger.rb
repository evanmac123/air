class Trigger::SurveyTrigger < ActiveRecord::Base
  belongs_to :task
  belongs_to :survey
end
