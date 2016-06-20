class Metrics < ActiveRecord::Base

  def self.by_start_and_end sdate, edate
    where(["weekending_date >= ? and weekending_date < ?",sdate, edate]).aggregate
  end

  def self.current_week
    sdate, edate = default_date_range
    by_start_and_end(sdate, edate)
  end

  def self.default_date_range
    this_week =Date.today.beginning_of_week
    sweek = this_week.advance(weeks: -5)
    [sweek, this_week]
  end

  def self.aggregate
    vals = self.select(kpi_fields.join(',')).map do |m|
      m.attributes
    end
    vals
  end

  def self.kpi_fields
    ["weekending_date", 
     "starting_customers",
     "added_customers",
     "cust_possible_churn",
     "cust_churned",
     "starting_mrr",
     "added_mrr",
     "new_cust_mrr",
     "upgrade_mrr",
     "possible_churn_mrr",
     "churned_mrr",
     "percent_churned_mrr",
     "net_churned_mrr",
    ]
  end


  def self.field_headers
    [
      ["Date","date"],
      ["Starting Customers","int"],
      ["Customers Added","int"],
      ["Possible Churn","int"],
      ["Churned","int"],
      ["Starting MRR", "money"],
      ["MRR Added","money"],
      ["New Customer MRR","money"],
      ["Upgrade MRR ","money"],
      ["MRR Possible Churn","money"],
      ["MRR Churned","money"],
      ["Percent MRR Churn","pct"],
      ["Net MRR Churn", "pct"]
    ]
  end

  def self.field_mapping
    Hash[field_headers.zip kpi_fields]
  end
end
