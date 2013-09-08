class Payment < ActiveRecord::Base
  belongs_to :balance
  belongs_to :user

  serialize :raw_stripe_charge
end
