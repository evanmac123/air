class Trigger::RuleTrigger < ActiveRecord::Base
  belongs_to :task
  belongs_to :rule
end
