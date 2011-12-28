class Trigger::SurveyTrigger < ActiveRecord::Base
  belongs_to :suggested_task
  belongs_to :survey
end
