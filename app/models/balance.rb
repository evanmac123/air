class Balance < ActiveRecord::Base
  attr_accessible :amount, :demo_id

  belongs_to :demo
  has_one :payment

  def pretty_amount
    dollars = amount / 100
    cents = sprintf("%02u", amount % 100)
    "$#{dollars}.#{cents}"
  end

  def billing_date
    created_at.to_date
  end

  def self.outstanding
    joins("LEFT JOIN payments ON payments.balance_id = balances.id").where("payments.id IS NULL")
  end
end
