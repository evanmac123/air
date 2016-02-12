class Organization < ActiveRecord::Base
  has_many :contracts

  validates :name, :sales_channel, :num_employees, presence: true
  validates :num_employees, numericality: {integer_only: true}


  def self.weekly_metrics sdate, edate
    prior = sdate-7
    m ={}
    m[:active_customers]=active_prior_to_and_beyond_date_range(sdate, edate).count
    m[:added]=added_during_period(sdate, edate)
    m[:possible_churn]=possible_churn(sdate, edate)
    m[:churned]=active_after_date(sdate)
    m[:customers]=active_after_date(sdate)
  end

  def self.active_during_period sdate, edate
    Organization.all.select{|o| o.customer_start_date && o.customer_end_date && o.customer_start_date <=  sdate && o.customer_end_date > edate}
  end

  def self.added_during_period sdate, edate
    Organization.all.select{|o| o.customer_start_date && o.customer_end_date && o.customer_start_date > sdate && o.customer_start_date < edate}
  end

  def self.possible_churn_during_period sdate, edate
    #active_after_date(sdate).select{|o| o.customer_end_date <= edate}.uniq
    Organization.all.select{|o| o.customer_start_date && o.customer_end_date && o.customer_end_date > sdate && o.customer_end_date <= edate}
  end

  def self.churned_during_period sdate, edate
    Organization.all.select{|o| o.customer_start_date && o.customer_end_date && o.customer_end_date > sdate && o.customer_end_date <= edate}
  end



  #def self.active_not_churning_during_date_range sdate, edate
    #active_prior_to_and_beyond_date_range(sdate, edate).having("count(organizations.id) > 0")
  #end

  #def self.active_prior_to_and_beyond_date_range sdate, edate
    #joins(:contracts).select("organizations.id, organizations.name")
      #.where("contracts.start_date < ? and contracts.end_date > ?", sdate, edate)
      #.group("organizations.id, organizations.name")
  #end

  def self.active_after_date date
    joins(:contracts)
      .select("organizations.id, organizations.name")
      .where("contracts.end_date > ?", date)
      .group("organizations.id, organizations.name")
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
