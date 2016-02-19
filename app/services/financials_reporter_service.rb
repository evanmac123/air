class FinancialsReporterService

  def execute sdate, edate
    kpi =  FinancialsCalcService.new(sdate, edate)

    m = Metric.new

    m.starting_customers= kpi.active_organizations_during_period
    m.added_customers= kpi.added_organizations_during_period
    m.cust_possible_churn= kpi.possible_churn_during_period
    m.cust_churned= kpi.churned_during_period
    m.starting_mrr=kpi.mrr_during_period
    m.added_mrr=kpi.mrr_added_during_period
    m.new_cust_mrr=kpi.new_customer_mrr_added_during_period
    m.upgrade_mrr=kpi.mrr_upgrades_during_period
    m.possible_churn_mrr=kpi.mrr_possibly_churning_during_period
    m.churned_mrr=kpi.mrr_churned_during_period
    m.percent_churned_mrr=kpi.percent_mrr_churn_during_period
    m.net_churned_mrr=kpi.net_mrr_churn_during_period
    m.weekending_date=edate
    m.save
  end
end
