class Organization < ActiveRecord::Base
  has_many :contracts

  validates :name, presence: true

  def customer_start_date
    @cust_start ||=ordered_contracts.try(:first).start_date
  end

  def customer_end_date
   @cust_end ||= ordered_contracts.try(:last).end_date
  end

  def active
    customer_end_date >= Date.today
  end

  def life_time
    TimeDifference.between(customer_start_date, customer_end_date).in_months
  end

  private

  def ordered_contracts
    contracts.order("start_date asc")
  end

end
