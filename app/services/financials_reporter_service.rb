class FinancialsReporterService < Reporting::KpiReportingBase
  REPORT_DATE_RANGE_TYPES = {
    "Past week" =>       1.week,
    "Past 30 days" =>    30.days,
    "Past 3 months" =>   3.months,
    "Past 12 months" =>  12.months,
    "Custom Range"   =>  -1
  }

  class << self

    def default_date_range
      sdate = Date.today.advance(days: -30)
      edate = Date.today.end_of_week
      [sdate, edate]
    end

    def totals
      {
        totalArr: current_arr.to_i,
        totalCustomers: active_customers,
        totalMrr: current_mrr.to_i,
      }
    end

    def current_mrr
      Contract.active_mrr_today
    end

    def current_amount_booked
      Contract.booked_year_to_date
    end

    def current_arr
      Contract.active_arr_today
    end

    def active_customers
      Organization.currently_active.count
    end
  end

  def chart_series_names
    kpi_fields.inject({}){|h, (k,v)| h[v[:series]]=k if v[:series]; h}
  end

  def row_set res
    if res.any?
      build_from_results res
    else
      build_from_null_set
    end
  end

  def group_separators 
    {"possible_churn" => "Possible Churn",
     "actual_churn" => "Actual Churn",
     "pct_churn" => "% Churn",
    }
  end

  def aliased_kpis container
    {
      churned_mrr_alias: {
        label:  "Churned",
        type: "money",
        indent: 0,
        values: container["churned_mrr"]["values"],
      } ,
      churned_customers_alias: {
        label:  "Churned",
        type: "num",
        indent: 0,
        values:  container["churned_customers"]["values"],
      } ,

    }
  end

  def kpi_fields
    {
      "from_date" => {
        label: "Date",
        type: "date",
        indent: 0
      },
      "starting_mrr" => {
        label: "Starting",
        series: "Starting MRR",
        type:"money",
        indent: 0
      },
      "added_mrr" => {
        label: "Added",
        series: "Added MRR",
        type: "money",
        indent: 0
      },

      "upgrade_mrr"  => {
        label: "Upgrades",
        series: "Upgrade MRR",
        type: "money",
        indent: 1
      },

      "new_cust_mrr" => {
        label: "New Customers",
        series: "New Cusomer MRR",
        type: "money",
        indent: 1
      },

      "churned_mrr" => {
        label: "Churned MRR",
        series: "Churned MRR",
        type: "money",
        indent: 0
      },
      "downgrade_mrr" => {
        label: "Downgrades",
        series: "Downgrade MRR",
        type: "money",
        indent: 1
      },
      "churned_customer_mrr" => {
        label: "Lost Customers",
        series: "Lost Customer MRR",
        type: "money",
        indent: 1
      },
      "net_changed_mrr" => {
        label: "Net Change",
        series: "Net Change MRR",
        type: "money",
        indent: 0
      } ,
      "current_mrr" => {
        label: "Ending",
        series: "Ending MRR",
        type: "money",
        indent: 0
      } ,
      "starting_customers" => {
        label: "Starting",
        series: "Starting Customers",
        type: "num",
        indent: 0
      } ,
      "added_customers" => {
        label: "Added",
        series: "Added Customers",
        type: "num"
      } ,
      "churned_customers" => {
        label: "Churned",
        series: "Churned Customers",
        type: "num",
        indent: 0
      } ,
      "net_change_customers" => {
        label: "Net Change",
        series: "Net Change Customers",
        type: "num",
        indent: 0
      } ,
      "current_customers" => {
        label: "Ending",
        series: "Customers",
        type: "num",
        indent: 0
      } ,
      "possible_churn_customers" => {
        label: "Customers",
        series: "Possible Churn Customers",
        type: "num",
        indent: 1
      } ,
      "possible_churn_mrr" => {
        label: "MRR",
        series: "Possible Churn MRR",
        type: "money",
        indent: 1
      } ,
      "churned_customers" => {
        label: "Customers",
        series: "Churned Customers",
        type: "num",
        indent: 1
      } ,
      "churned_mrr" => {
        label: "MRR",
        series: "Churned MRR",
        type: "money",
        indent: 1
      } ,
      "percent_churned_customers" => {
        label: "Customers",
        series: "% Churned Customers",
        type: "pct",
        indent: 1
      } ,
      "percent_churned_mrr" => {
        label: "MRR",
        series: "% Churned MRR",
        type: "pct 0",
        indent: 1
      } ,
      "net_churned_mrr" => {
        label: "Net Churned Rate",
        series: "Net Churned MRR %",
        type: "pct",
        indent: 0
      } ,
      "added_customer_amt_booked" => {
        label: "New Customer",
        series: "New Customer Amt Booked",
        type: "money",
        indent: 0
      },
      "renewal_amt_booked" => {
        label: "Renewals",
        series: "Renewal Amt Booked",
        type: "money",
        indent: 0
      } ,
      "upgrade_amt_booked" => {
        label: "Upgrades",
        series: "Upgrade Amt Booked",
        type: "money",
        indent: 0
      } ,
      "amt_booked" => {
        label: "Total",
        series: "Amt Booked",
        type: "money",
        indent: 0
      } ,
    }
  end

  def sections
    {

      "MRR" =>  [
        "starting_mrr",
        "added_mrr",
        "upgrade_mrr",
        "new_cust_mrr",
        "churned_mrr_alias",
        "downgrade_mrr",
        "churned_customer_mrr",
        "net_changed_mrr",
        "current_mrr"
      ],

      "Customers" => [ 
        "starting_customers",
        "added_customers",
        "churned_customers_alias",
        "net_change_customers",
        "current_customers",
      ],

      "Churn" => [ 
        "possible_churn",
        "possible_churn_customers",
        "possible_churn_mrr",
        "actual_churn",
        "churned_customers",
        "churned_mrr",
        "pct_churn",
        "percent_churned_customers",
        "percent_churned_mrr",
        "net_churned_mrr",
      ],

      "Bookings" => [
        "amt_booked",
        "added_customer_amt_booked",
        "upgrade_amt_booked",
        "renewal_amt_booked",
      ]
    }
  end

  def db_fields
    Metrics.select(query_select_fields)
  end

  private

  def build_from_results res
    fields = res.map(&:keys).flatten.uniq
    values = res.map(&:values).transpose

    Hash[fields.zip(values)]
  end

  def build_from_null_set
    fields = kpi_fields.keys
    values =fields.map{|f| f=="from_date" ? [Date.today] : [0]}
    Hash[fields.zip(values)]
  end


  def generate_csv table
    CSV.generate do |csv|
      table.each do|row|
        csv << row
      end
    end
  end
end
