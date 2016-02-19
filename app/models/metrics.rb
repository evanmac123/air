class Metrics < ActiveRecord::Base
  attr_accessible :added_customers, :cust_churned, :cust_possible_churn, :starting_customers
end
