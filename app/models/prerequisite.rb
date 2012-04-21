class Prerequisite < ActiveRecord::Base
  belongs_to :task
  belongs_to :prerequisite_task, :class_name => "Task"
end
