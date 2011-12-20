class Prerequisite < ActiveRecord::Base
  belongs_to :suggested_task
  belongs_to :prerequisite_task, :class_name => "SuggestedTask"
end
