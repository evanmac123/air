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

  def self.current_mrr
    Contract.active_mrr_for_date
  end

  def self.current_amount_booked
    Contract.active_booked_for_date
  end

  def self.active_customers
    Contract.active.includes(:organization).count
  end

  def self.default_date_range
    edate = Date.today.beginning_of_week
    sdate = edate.advance(weeks: -5)
    [sdate, edate]
  end

  def self.get_data_by_date sdate, edate
    self.build_data_set(raw_data(sdate, edate))
  end

  def self.build_data_set res
    fields = res.map(&:keys).flatten.uniq
    values = res.map(&:values).transpose
    container = Metrics.record_hash
    new_hash =Hash[fields.zip values]
    container.each do|field, sub_hash|
      sub_hash["values"]=new_hash[field] 
      sub_hash["label"]=field_to_label_map[field]
    end
    container
  end


  def self.raw_data sdate, edate
    Metrics.normalized_by_start_and_end sdate, edate 
  end

  def self.generate_csv table
    CSV.generate do |csv|
      table.each do|row|
        csv << row
      end
    end
  end

  def self.totals
    {
      totalBooked: current_amount_booked.to_i,
      totalCustomers: active_customers,
      totalMrr: current_mrr.to_i,
    }
  end

   def self.field_to_label_map
    {"weekending_date"=>"Date",
     "starting_customers"=>"Starting Customers",
     "added_customers"=>"Customers Added",
     "cust_possible_churn"=>"Possible Churn",
     "cust_churned"=>"Churned",
     "starting_mrr"=>"Starting MRR",
     "added_mrr"=>"MRR Added",
     "new_cust_mrr"=>"New Customer MRR",
     "upgrade_mrr"=>"Upgrade MRR ",
     "possible_churn_mrr"=>"MRR Possible Churn",
     "churned_mrr"=>"MRR Churned",
     "percent_churned_mrr"=>"Percent MRR Churn",
     "net_churned_mrr"=>"Net MRR Churn"}
  end
end
