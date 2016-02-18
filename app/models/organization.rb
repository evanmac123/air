class Organization < ActiveRecord::Base
  has_many :contracts

  validates :name, :sales_channel, :num_employees, presence: true
  validates :num_employees, numericality: {integer_only: true}


  def self.active_during_period sdate, edate
    all.select{|o| o.has_start_and_end && o.customer_start_date <=  sdate && o.customer_end_date > edate}
  end

  def self.added_during_period sdate, edate
    all.select{|o| o.has_start_and_end && o.customer_start_date > sdate && o.customer_start_date < edate}
  end

  def self.possible_churn_during_period sdate, edate
    all.select{|o| o.has_start_and_end && o.customer_end_date > sdate && o.customer_end_date <= edate}
  end

  def self.churned_during_period sdate, edate
    possible_churn_during_period(sdate, edate).select{|o|o.contracts.auto_renewing.count == 0}
  end

  def self.new_customer_arr_added_during_period sdate, edate
   added_during_period(sdate,edate).inject(0){|sum,org| sum += org.arr_during_period(sdate,edate)}
  end

  def self.new_customer_mrr_added_during_period sdate, edate
    added_during_period(sdate,edate).inject(0){|sum,org | sum+= org.mrr_during_period(sdate,edate)}
  end

  def active_mrr 
    contracts.active.sum(&:calc_mrr)
  end

  def arr_during_period sdate, edate
    contracts.arr_during_period(sdate, edate)
  end

  def mrr_during_period sdate, edate
    contracts.mrr_during_period(sdate, edate)
  end

  def self.active_after_date date
    joins(:contracts)
      .select("organizations.id, organizations.name")
      .where("contracts.end_date > ?", date)
      .group("organizations.id, organizations.name")
  end

  def self.active
    all.select{|o|o.active==true}
  end

  def self.churned
    all.select{|o|o.churned==true}
  end

  def customer_start_date
    @cust_start ||=ordered_contracts.first.try(:start_date)
  end

  def customer_end_date
   @cust_end ||= ordered_contracts.last.try(:end_date)
  end

  def active
   !churned 
  end

  def churned 
   customer_end_date && customer_end_date < Date.today 
  end

  def has_start_and_end
    customer_start_date && customer_end_date
  end


  def life_time
    TimeDifference.between(customer_start_date, customer_end_date).in_months
  end

  private
 
  def ordered_contracts
    contracts.order("start_date asc")
  end

end
