class Trigger::RuleTrigger < ActiveRecord::Base
  belongs_to :tile
  belongs_to :rule
end
