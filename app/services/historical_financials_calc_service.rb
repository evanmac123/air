class HistoricalFinancialsCalcService < FinancialsCalcService
  attr_accessor :report_date, :sdate, :edate, :last_week

  protected

  def churned_customers
    Organization.possible_churn_during_period(sdate, edate).select{|o|o.contracts.where("start_date >  && start_date < ",edate, sdate.advance(weeks: 1) )}
  end


  def churned_customer_mrr
   @churned_cust_mrr ||= churned_customers.sum{|c|c.mrr_during_period sdate, edate}
  end

end






