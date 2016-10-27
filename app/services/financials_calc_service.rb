class FinancialsCalcService
  attr_accessor :report_date, :sdate, :edate, :last_week

  def initialize(report_date=Date.today)
    @report_date = report_date 
    @last_week = report_date.advance(weeks: -1) 

    @sdate = report_date.advance(weeks: -1) 
    @edate = report_date.advance(days: -1)
  end

  #------------------------
  # Customer Methods
  #_________________________

  def starting_customers
    @starting_cust ||=Organization.active_as_of_date sdate
  end

  def current_customers
    @current_cust ||=Organization.active_as_of_date edate
  end


  def added_customers
    @cust_added ||= Organization.added_during_period sdate, edate
  end

  def net_change_in_customers
    current_customers.count - starting_customers.count
  end

  def retained_customers
    @retained_customers ||= current_customers-added_customers
  end

  def customers_possibly_churning
    Organization.possible_churn_during_period(sdate, edate)
  end

  def lost_customers
    @lost_customers ||=starting_customers - retained_customers
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

  def lost_customer_mrr
    @lost_cust_mrr ||= lost_customers.sum{|c|c.mrr_as_of_date(sdate)}
  end

  def mrr_possibly_churning
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

  def mrr_added
    @mrr_add ||= upgrade_mrr + new_customer_mrr
  end

  def mrr_churned
    @mrr_churned ||= downgrade_mrr - lost_customer_mrr
  end


  def amount_booked_during_period sdate, edate
    booked_during_period
  end



end
