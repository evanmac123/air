class FinancialsReporterService
  def self.build_week sdate, edate
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
        build_week sdate, edate
        sdate = sdate.advance(weeks: 1)
        edate = edate.advance(weeks: 1)
      end
    end
  end

  def self.to_csv sdate, edate 
    generate_csv(self.tabular_data_by_date(sdate, edate))
  end

  def self.tabular_data_by_date sdate, edate
    self.to_table(raw_data(sdate, edate))
  end

  def self.plot_data_by_date sdate, edate
    self.to_plot_data(raw_data(sdate, edate))
  end

  def self.raw_data sdate, edate
    Metrics.by_start_and_end(sdate, edate)
  end

  def self.generate_csv table
    CSV.generate do |csv|
      table.each do|row|
        csv << row
      end
    end
  end

  def self.current_mrr
    Contract.active_mrr_for_date
  end

  def self.current_amount_booked
    Contract.active_booked_for_date
  end

  def self.active_customers
    Contract.active.includes(:organization).count
  end


  def self.to_table metric_set_array
    table =[]
    Metrics.label_field_mapping.each do|label, metric|
      rows=[]
      rows[0]=label

      metric_set_array.each do|metric_set|
        rows << metric_set[metric]
      end

      table << rows
    end
   table
  end

  def self.to_plot_data metric_set_array
    hash_table ={}
    Metrics.kpi_fields.each do|metric|
      rows = []
      metric_set_array.each do|metric_set|
        rows << metric_set[metric]
      end
      hash_table[metric]=rows
    end
    hash_table["weekending_date"].map{|d| d.to_time.to_i*1000}.zip(hash_table["starting_mrr"])
  end

  def self.default_date_range
    Metrics.default_date_range
  end

end
