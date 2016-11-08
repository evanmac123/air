class FinancialsReporterService 

  def self.build_week date
    kpi =  FinancialsCalcService.new(date)

    m = Metrics.new

    m.starting_mrr = kpi.starting_mrr
    m.added_mrr = kpi.added_mrr
    m.upgrade_mrr = kpi.upgrade_mrr
    m.new_cust_mrr = kpi.new_customer_mrr
    m.churned_mrr = kpi.churned_mrr
    m.downgrade_mrr = kpi.downgrade_mrr
    m.churned_customer_mrr = kpi.churned_customer_mrr
    m.net_changed_mrr = kpi.net_changed_mrr
    m.net_churned_mrr = kpi.net_churned_mrr
    m.current_mrr = kpi.current_mrr
    m.possible_churn_mrr =kpi.possible_churn_mrr
    m.percent_churned_mrr =kpi.percent_churned_mrr
    m.starting_customers = kpi.starting_customer_count
    m.added_customers = kpi.added_customer_count
    m.churned_customers = kpi.churned_customer_count
    m.net_change_customers = kpi.net_change_in_customers
    m.current_customers = kpi.current_customer_count
    m.possible_churn_customers = kpi.possible_churn_customer_count
    m.percent_churned_customers = kpi.percent_churned_customers
    m.amt_booked =kpi.amt_booked
    m.added_customer_amt_booked =kpi.added_customer_amt_booked
    m.renewal_amt_booked =kpi.renewal_amt_booked
    m.weekending_date = kpi.edate
    m.save
  end


  def self.build_historical(date = nil)
    if Contract.count==0 || Organization.count == 0
      Rails.logger.warn "Skipping Activity Report Not Monday"
    else
      min_start = date || Contract.min_activity_date
      sdate = min_start.beginning_of_week
      edate = sdate.end_of_week
      while sdate < Date.today do 
        build_week sdate
        sdate = sdate.advance(weeks: 1)
        edate = edate.advance(weeks: 1)
      end
    end
  end

  def self.current_mrr
    Contract.active_mrr_today
  end

  def self.current_amount_booked
    Contract.booked_year_to_date
  end

  def self.current_arr
    Contract.active_arr_today
  end

  def self.active_customers
    Organization.currently_active.count
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
      sub_hash["display"]=kpi_field_display_type_map[field]
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
      totalArr: current_arr.to_i,
      totalCustomers: active_customers,
      totalMrr: current_mrr.to_i,
    }
  end

    }
  end


    }
  end
end
