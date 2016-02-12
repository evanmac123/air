class FinancialsKpiPresenter
  
  def initialize date
    @date = date
  end

  def active_contracts
    Contract.active
  end

  def active_clients_by_date date
    Organization.active_by_date date
  end

  def possible_churn_by sdate, edate 
    Organization.possible_churn sdate, edate
  end

  def churned

  end

  def pct_churned

  end

  def weekly_ending

  end


end
