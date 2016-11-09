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
    self.build_data_set(row_set(raw_data(sdate, edate)))
  end

  def self.build_data_set row_data 
    container = HashWithIndifferentAccess.new(kpi_fields)
    container.each do|field, sub_hash|
      sub_hash[:values] = row_data[field]
    end
    container
  end


  def self.row_set res
    fields = res.map(&:keys).flatten.uniq
    values = res.map(&:values).transpose
    Hash[fields.zip(values)]
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

  def self.kpi_fields
    {  
      "weekending_date" => {
        label: "Date",
        type: "date"
      },
      "starting_mrr" => {
        label: "Starting MRR",
        type:"money" 
      },
      "added_mrr" => {
        label: "Added MRR",
        type: "money"
      },

      "upgrade_mrr"  => {
        label: "Upgrade MRR",
        type: "money"
      },

      "new_cust_mrr" => {
        label: "New Customer MRR",
        type: "money"
      },

      "churned_mrr" => {
        label: "Churned MRR",
        type: "money"
      },
      "downgrade_mrr" => {
        label: "Downgrade MRR",
        type: "money"
      },
      "churned_customer_mrr" => {
        label: "Churned Customer MRR",
        type: "money"
      },
      "net_changed_mrr" => {
        label: "Net Change MRR",
        type: "money"
      } ,
      "current_mrr" => {
        label: "Ending MRR",
        type: ""
      } ,
      "starting_customers" => {
        label: "Starting Customers",
        type: "num"
      } ,
      "added_customers" => {
        label: "Added Customers",
        type: "num"
      } ,
      "churned_customers" => {
        label: "Churned Customers",
        type: "num"
      } ,
      "net_change_customers" => {
        label: "Net Change Customers",
        type: "num"
      } ,
      "current_customers" => {
        label: "Ending Customers",
        type: "num"
      } ,
      "possible_churn_customers" => {
        label: "Possible Churn Customers",
        type: "num"
      } ,
      "possible_churn_mrr" => {
        label: "Possible Churn MRR",
        type: "money"
      } ,
      "churned_customers" => {
        label: "Churned Customers",
        type: "num"
      } ,
      "churned_mrr" => {
        label: "Churned MRR",
        type: "money"
      } ,
      "percent_churned_customers" => {
        label: "Percent Churned Customers",
        type: "pct"
      } ,
      "percent_churned_mrr" => {
        label: "Percent Churned MRR",
        type: "pct"
      } ,
      "net_churned_mrr" => {
        label: "Net Churned MRR",
        type: "pct"
      } ,
      "added_customer_amt_booked" => {
        label: "New Customer Booked",
        type: "money"
      },
      "renewal_amt_booked" => {
        label: "Renewals Booked",
        type: "money"
      } ,
      "amt_booked" => {
        label: "Total Booked",
        type: "money"
      } ,
    }
  end


  def self.query_select_fields
    kpi_fields.keys.join(",")
  end 

  def self.sections
    { 

      "MRR" =>  [
        "starting_mrr",
        "added_mrr",
        "upgrade_mrr",
        "new_cust_mrr",
        "churned_mrr",
        "downgrade_mrr",
        "churned_customer_mrr",
        "net_changed_mrr",
        "current_mrr"
    ],

    "Customers" => [ 
      "starting_customers",
      "added_customers",
      "churned_customers",
      "net_change_customers",
      "current_customers",
      "possible_churn_customers",
      "possible_churn_mrr",
      "churned_customers",
    ],

    "Churn" => [ 
      "possible_churn_customers",
      "possible_churn_mrr",
      "churned_customers",
      "churned_mrr",
      "percent_churned_customers",
      "percent_churned_mrr",
      "net_churned_mrr",
    ],

    "Bookings" => [
      "added_customer_amt_booked",
      "renewal_amt_booked",
      "amt_booked",
    ]

    }
  end

end
