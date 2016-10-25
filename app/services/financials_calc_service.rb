class FinancialsCalcService
  attr_accessor :report_date, :sdate, :edate 

  def initialize(report_date=Date.today)
    @report_date = report_date 
    @sdate = report_date.advance(weeks: -1) 
    @edate = report_date.advance(days: -1) 
  end

  def starting_mrr
    @starting_mrr ||=Contract.active_mrr_as_of_date report_date.advance(weeks: -1)
  end


  def current_mrr
    @current_mrr ||= Contract.active_mrr_as_of_date report_date
  end

   def new_cust_mrr
     Organization.new_customer_mrr_added_during_period(sdate, edate)
   end

   def net_changed_mrr
     @net_change ||=current_mrr - starting_mrr
   end

   def churned_mrr
     net_changed_mrr < 0 ? net_changed_mrr : 0 
   end

   def downgrade_mrr
     
   end

   #def starting_customers
   #def added_customers
   #def cust_possible_churn
   #def cust_churned
   #def added_mrr
   #def upgrade_mrr
   #def possible_churn_mrr
   #def churned_mrr
   #def percent_churned_mrr
   #def net_churned_mrr
   #def created_at
   #def updated_at
   #def weekending_date
   #def amt_booked
   #def interval


 

  def active_organizations_during_period 
    Organization.active_during_period(sdate, edate).count
  end


  #NOTE could possible use the result of active_during_period
  def added_organizations_during_period 
    Organization.added_during_period(sdate, edate).count
  end

  def new_customer_mrr_added_during_period
    Organization.new_customer_mrr_added_during_period(sdate, edate) #OK
  end

  def mrr_upgrades_during_period
    Contract.mrr_added_during_period(sdate, edate) - new_customer_mrr_added_during_period
  end

  def possible_churn_during_period
    Organization.possible_churn_during_period(sdate, edate).count
  end

  def churned_during_period
    Organization.churned_during_period(sdate, edate).count
  end

  def mrr_during_period
    @starting_mrr ||=Contract.mrr_during_period(sdate, edate)
  end

  def mrr_added_during_period
    @mrr_add ||= Contract.mrr_added_during_period(sdate, edate)
  end

  def mrr_possibly_churning_during_period
    Contract.mrr_possibly_churning_during_period(sdate, edate)
  end

  def amount_booked_during_period sdate, edate
    booked_during_period
  end

  def mrr_churned_during_period
    @churned_mrr ||= Contract.mrr_churned_during_period(sdate, edate)
  end

  def percent_mrr_churn_during_period
    return 0 if mrr_churned_during_period == 0
    mrr_possibly_churning_during_period/mrr_churned_during_period
  end

  def net_mrr_churn_during_period
    Contract.net_mrr_churn_during_period
  end



  private

  def active_contracts_during_period
    Contract.active_during_period(sdate, edate).count
  end

  def added_contracts_during_period
    Contract.added_during_period(sdate, edate).count
  end

  def arr_possibly_churning_during_period
    Contract.arr_possibly_churning_during_period(sdate, edate)
  end

  def arr_during_period
    Contract.arr_during_period(sdate, edate)
  end

  def arr_added_during_period
    Contract.arr_added_during_period(sdate, edate)
  end

  def new_customer_arr_added_during_period
    Organization.new_customer_arr_added_during_period(sdate, edate)
  end

  def arr_added_from_upgrades_during_period
    Contract.arr_added_from_upgrades_during_period(sdate, edate)
  end


end
