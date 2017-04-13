class FinancialsCalcService
  attr_accessor :report_date, :sdate, :edate

  def initialize(sdate, edate)
    @sdate =  sdate
    @edate =  edate
  end

  #------------------------
  # Customer Methods
  #_________________________

  def starting_customers
    @starting_cust ||=Organization.active_as_of_date sdate
  end

  def starting_customer_count
    starting_customers.count
  end

  def current_customers
    @current_cust ||=Organization.active_as_of_date edate
  end

  def current_customer_count
    current_customers.count
  end

  def added_customers
    @cust_added ||= Organization.added_during_period sdate, edate
  end

  def added_customer_count
    added_customers.count
  end

  def net_change_in_customers
    current_customer_count - starting_customer_count
  end

  def retained_customers
    @retained_customers ||= current_customers-added_customers
  end

  def retained_customer_count
    retained_customers.count
  end

  def possible_churn_customers
   @possible_churn_customer ||=  Organization.possible_churn_during_period(sdate, edate)
  end
  
  def possible_churn_customer_count
    possible_churn_customers.count
  end

  def delinquent_customers
    @delinquent_customers = Organization.with_deliquent_contracts_as_of_date(sdate)
  end

  def churned_customers
    @churned_customers ||=starting_customers - current_customers
  end

  def churned_customer_count
    churned_customers.count
  end

  def percent_churned_customers
    possible_churn_customer_count == 0 ? 0 : churned_customer_count/possible_churn_customer_count.to_f * 100
  end

  #------------------------
  # Basic MRR Methods
  #_________________________


  def starting_mrr
    @starting_mrr ||=Contract.mrr_during_period sdate, edate
  end

  def current_mrr
    @current_mrr ||=Contract.active_mrr_as_of_date edate
  end

  def net_changed_mrr
    @net_change ||=current_mrr - starting_mrr
  end

  def new_customer_mrr
    @new_cust_mrr ||= added_customers.sum{|c|c.mrr_as_of_date(edate)}
  end

  def churned_customer_mrr
    @lost_cust_mrr ||= churned_customers.sum{|c|c.mrr_as_of_date(sdate)}
  end

  def possible_churn_mrr
    Contract.mrr_possibly_churning_during_period(sdate, edate)
  end

  #------------------------
  # Upgades/Downgrad MRR Methods
  #_________________________


  def retained_customer_churn
    retained_customers.map{|c|c.mrr_churn_during_period(sdate, edate)}
  end

  def upgrade_mrr
   @upgrade_mrr ||= retained_customer_churn.select{|i|i>0}.sum
  end

  def downgrade_mrr
   @downgrade_mrr ||= retained_customer_churn.select{|i|i<0}.sum
  end

  def added_mrr
    @mrr_add ||= upgrade_mrr + new_customer_mrr
  end

  def churned_mrr
    @mrr_churned ||= downgrade_mrr - churned_customer_mrr
  end

  def net_churned_mrr
    starting_mrr == 0 ? 0 : (upgrade_mrr - churned_mrr)/starting_mrr.to_f * 100
  end

  def percent_churned_mrr
    possible_churn_mrr == 0 ? 0 : (churned_mrr.abs/possible_churn_mrr.to_f) * 100
  end

  def amt_booked
   @amt_booked ||= Contract.booked_during_period(sdate, edate)
  end

  def added_customer_amt_booked
    amt_booked - upgrade_amt_booked - renewal_amt_booked
  end

  def upgrade_amt_booked
    @upgrade_amt ||= Contract.upgrades.booked_during_period(sdate,edate)
  end

  def renewal_amt_booked
    retained_customers.sum{|o|o.contracts.booked_during_period(sdate, edate)} - upgrade_amt_booked
  end

  def to_json
    {
      starting_mrr: starting_mrr,
      added_mrr: added_mrr,
      upgrade_mrr: upgrade_mrr,
      new_cust_mrr: new_customer_mrr,
      churned_mrr: churned_mrr,
      downgrade_mrr: downgrade_mrr,
      churned_customer_mrr: churned_customer_mrr,
      net_changed_mrr: net_changed_mrr,
      net_churned_mrr: net_churned_mrr,
      current_mrr: current_mrr,
      possible_churn_mrr: possible_churn_mrr,
      percent_churned_mrr: percent_churned_mrr,
      starting_customers: starting_customer_count,
      added_customers: added_customer_count,
      churned_customers: churned_customer_count,
      net_change_customers: net_change_in_customers,
      current_customers: current_customer_count,
      possible_churn_customers: possible_churn_customer_count,
      percent_churned_customers: percent_churned_customers,
      amt_booked: amt_booked,
      added_customer_amt_booked: added_customer_amt_booked,
      renewal_amt_booked: renewal_amt_booked,
      upgrade_amt_booked: upgrade_amt_booked,
      from_date: sdate,
      to_date: edate,
    }.to_json
  end

end
