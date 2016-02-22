class FinancialsReporterService
  def self.execute sdate, edate
    kpi =  FinancialsCalcService.new(sdate, edate)

    m = Metrics.new

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

  def self.build_historical 
    if Contract.count==0 || Organization.count == 0
      Rails.logger.warn "Skipping Activity Report Not Monday"
    else
      min_start = Contract.minimum(:start_date)
      sdate = min_start.beginning_of_week
      edate = sdate.end_of_week
      while sdate < Date.today do 
        FinancialsReporterService.execute sdate, edate
        sdate = sdate.advance(weeks: 1)
        edate = edate.advance(weeks: 1)
      end
    end
  end

  def self.to_csv sdate, edate 
    data = Metrics.by_start_and_end sdate, edate
    table = self.to_table data
    CSV.generate do |csv|
      table.each do|row|
        csv << row
      end
    end
  end

  def self.to_table data
    table =[]
    Metrics.field_mapping.each do|mapping, meth|
      rows=[]  
      rows[0]=mapping[0]
      data.each do|h,v|
        rows << h[meth] 
      end
      table << rows
    end
   table
  end

    
end
