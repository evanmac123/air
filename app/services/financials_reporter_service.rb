class FinancialsReporterService 
  REPORT_DATE_RANGE_TYPES = {
    "Past week" =>       1.week,
    "Past 30 days" =>    30.days,
    "Past 3 months" =>   3.months,
    "Past 12 months" =>  12.months,
    "Custom Range"   =>  -1
  }

  class << self


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

    def default_date_range
      sdate = Date.today.advance(days: -30)
      edate = Date.today.end_of_week
      [sdate, edate]
    end

    def get_data_by_date_and_interval sdate, edate, interval
      build_data_set(row_set(to_array_of_record_hashes(raw_data(sdate, edate, interval))))
    end


    def raw_data sdate, edate, interval=Metrics::WEEKLY
      Metrics.select(query_select_fields).normalized_by_date_range_and_interval(sdate, edate, interval)
    end

    def to_array_of_record_hashes results
      results.map(&:attributes)
    end

    def build_data_set rows 
      container = HashWithIndifferentAccess.new(kpi_fields)
      return container if rows.empty? 
      container.each do|field, sub_hash|
        sub_hash[:values] = rows[field]
      end
      add_group_separators(container)
      container.merge!(aliased_kpis(container))
      container
    end

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

    def row_set res
      if res.any?
        build_from_results res
      else
        build_from_null_set
      end
    end


    def add_group_separators(container)
      group_separators.each do |key, label|
        add_group_separator(container, key, label)
      end
      container
    end

    def add_group_separator container, key, label
      colspan = container["from_date"]["values"].count + 1
      container[key]= {
        label: label,
        colspan: colspan,
        type: "grp",
        indent: 0,
        values: []
      }
      container
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

    def totals
      {
        totalArr: current_arr.to_i,
        totalCustomers: active_customers,
        totalMrr: current_mrr.to_i,
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
          type:"money",
          indent: 0
        },
        "added_mrr" => {
          label: "Added",
          type: "money",
          indent: 0
        },

        "upgrade_mrr"  => {
          label: "Upgrades",
          type: "money",
          indent: 1
        },

        "new_cust_mrr" => {
          label: "New Customers",
          type: "money",
          indent: 1
        },

        "churned_mrr" => {
          label: "Churned MRR",
          type: "money",
          indent: 0
        },
        "downgrade_mrr" => {
          label: "Downgrades",
          type: "money",
          indent: 1
        },
        "churned_customer_mrr" => {
          label: "Lost Customers",
          type: "money",
          indent: 1
        },
        "net_changed_mrr" => {
          label: "Net Change",
          type: "money",
          indent: 0
        } ,
        "current_mrr" => {
          label: "Ending",
          type: "money",
          indent: 0
        } ,
        "starting_customers" => {
          label: "Starting",
          type: "num",
          indent: 0
        } ,
        "added_customers" => {
          label: "Added",
          type: "num"
        } ,
        "churned_customers" => {
          label: "Churned",
          type: "num",
          indent: 0
        } ,
        "net_change_customers" => {
          label: "Net Change",
          type: "num",
          indent: 0
        } ,
        "current_customers" => {
          label: "Ending",
          type: "num",
          indent: 0
        } ,
        "possible_churn_customers" => {
          label: "Customers",
          type: "num",
          indent: 1
        } ,
        "possible_churn_mrr" => {
          label: "MRR",
          type: "money",
          indent: 1
        } ,
        "churned_customers" => {
          label: "Customers",
          type: "num",
          indent: 1
        } ,
        "churned_mrr" => {
          label: "MRR",
          type: "money",
          indent: 1
        } ,
        "percent_churned_customers" => {
          label: "Customers",
          type: "pct",
          indent: 1
        } ,
        "percent_churned_mrr" => {
          label: "MRR",
          type: "pct 0",
          indent: 1
        } ,
        "net_churned_mrr" => {
          label: "Net Churned Rate",
          type: "pct",
          indent: 0
        } ,
        "added_customer_amt_booked" => {
          label: "New Customer",
          type: "money",
          indent: 0
        },
        "renewal_amt_booked" => {
          label: "Renewals",
          type: "money",
          indent: 0
        } ,
        "upgrade_amt_booked" => {
          label: "Upgrades",
          type: "money",
          indent: 0
        } ,
        "amt_booked" => {
          label: "Total",
          type: "money",
          indent: 0
        } ,
      }
    end


    def query_select_fields
      kpi_fields.keys.join(",")
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

    def generate_csv table
      CSV.generate do |csv|
        table.each do|row|
          csv << row
        end
      end
    end
  end
end
