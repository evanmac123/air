class Trigger::DemographicTrigger < ActiveRecord::Base
  belongs_to :suggested_task
end
