class Organization < ActiveRecord::Base
  attr_accessible :churn_reason, :churned, :name, :num_employees, :sales_channel
end
