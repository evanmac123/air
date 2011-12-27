class Trigger::RuleTrigger < ActiveRecord::Base
  belongs_to :suggested_task
  belongs_to :rule
end
