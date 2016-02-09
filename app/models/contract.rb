class Contract < ActiveRecord::Base
  belongs_to :organization
  attr_accessible :amt_booked, :arr, :date_booked, :end_date, :estimate_type, :max_users, :mrr, :name, :notes, :plan, :rank, :start_date, :term
end
