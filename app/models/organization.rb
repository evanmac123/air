class Organization < ActiveRecord::Base
  has_many :contracts

  validates :name, :sales_channel, :num_employees, presence: true
  validates :num_employees, numericality: {integer_only: true}

  def self.active_by_date date
    joins(:contracts).where("contracts.end_date > ?", date)
  end

  def self.expiring_within_date_range sdate, edate
    joins(:contracts).where("contracts.end_date > ? and contracts.end_date < ?", sdate, edate)
  end

  def self.still_active_beyond_date_range sdate, edate
    joins(:contracts).where("contracts.end_date > ? and contracts.end_date > ?", sdate, edate)
  end

  def self.possible_churn sdate, edate
    still_active_beyond_date_range(sdate, edate)
      .select("organization.id, organization.name")
      .group("organization.id, organization.name")
      .having("count(organization.id)") > 0
  end

  def customer_start_date
    @cust_start ||=ordered_contracts.first.try(:start_date)
  end

  def customer_end_date
   @cust_end ||= ordered_contracts.last.try(:end_date)
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
