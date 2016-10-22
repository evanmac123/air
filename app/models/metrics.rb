class Metrics < ActiveRecord::Base

  def self.by_start_and_end sdate, edate
    where(["weekending_date >= ? and weekending_date < ?",sdate, edate]).to_array_of_record_hashes
  end

  def self.current_week
    sdate, edate = default_date_range
    by_start_and_end(sdate, edate)
  end


  def self.current_week_with_date_range
   [by_start_and_end(*default_date_range),@sweek, @this_week]
  end


  def self.default_date_range
    @this_week =Date.today.beginning_of_week
    @sweek = @this_week.advance(weeks: -5)
    [@sweek, @this_week]
  end

  def self.to_array_of_record_hashes
    #Note self is an active record relation
    self.select(qry_select_stmt).map do |record|
      normalize_values(record)
    end

  end

  def self.normalize_values record
    record.attributes.inject({}) do |normalized,(field,value)|
      normalized[field] = convert_to_int_if_big_decimal(value)
      normalized
    end
  end

  def self.convert_to_int_if_big_decimal field_value
    field_value.class==BigDecimal ? field_value.to_i : field_value
  end

  def self.qry_select_stmt
    kpi_fields.join(',')
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

  def self.metric_labels
    field_headers.map{|fh|fh[0]}
  end

  def self.label_field_mapping
    Hash[metric_labels.zip kpi_fields]
  end

  def self.field_mapping
    Hash[field_headers.zip kpi_fields]
  end

end
