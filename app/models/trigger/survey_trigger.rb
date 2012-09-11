class Trigger::SurveyTrigger < ActiveRecord::Base
  belongs_to :tile
  belongs_to :survey
end
