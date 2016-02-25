class FinancialsCalcService
  attr_accessor :sdate, :edate 

  def initialize(sdate = 1.week.ago.to_date, edate=Date.today)
    @sdate = sdate
    @edate = edate
  end

 

  def active_organizations_during_period 
    Organization.active_during_period(sdate, edate).count
  end

  def added_organizations_during_period 
    Organization.added_during_period(sdate, edate).count
  end

  def possible_churn_during_period
    Organization.possible_churn_during_period(sdate, edate).count
  end

  def churned_during_period
    Organization.churned_during_period(sdate, edate).count
  end

  def new_customer_mrr_added_during_period
    Organization.new_customer_mrr_added_during_period(sdate, edate)
  end

  def mrr_during_period
    @starting_mrr ||=Contract.mrr_during_period(sdate, edate)
  end

  def mrr_upgrades_during_period
    @upgrade_mrr ||= Contract.mrr_added_from_upgrades_during_period(sdate, edate)
  end

  def mrr_added_during_period
    @mrr_add ||= Contract.mrr_added_during_period(sdate, edate)
  end

  def mrr_possibly_churning_during_period
    Contract.mrr_possibly_churning_during_period(sdate, edate)
  end

  def mrr_churned_during_period
    @churned_mrr ||= Contract.mrr_churned_during_period(sdate, edate)
  end

  def percent_mrr_churn_during_period
    return 0 if mrr_churned_during_period == 0
    mrr_possibly_churning_during_period/mrr_churned_during_period
  end

  def net_mrr_churn_during_period
    return 0 if mrr_churned_during_period == 0
    (mrr_upgrades_during_period-mrr_churned_during_period)/mrr_during_period
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