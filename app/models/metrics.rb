class Metrics < ActiveRecord::Base

  def self.normalized_by_start_and_end sdate, edate
    by_start_and_end(sdate, edate).to_array_of_record_hashes
  end

  def self.current_week
    by_start_and_end(*default_date_range)
  end

  def self.current_week_with_date_range
    [by_start_and_end(*default_date_range),@sweek, @this_week]
  end

  def self.by_start_and_end sdate, edate
    where(["weekending_date >= ? and weekending_date < ?",sdate, edate])
  end

  def self.default_date_range
    @this_week =Date.today.beginning_of_week
    @sweek = @this_week.advance(weeks: -5)
    [@sweek, @this_week]
  end

  def self.to_array_of_record_hashes
    #Note self is an active record relation
    results.map do |record|
      normalize_values(record)
    end
  end

  def self.results
    select(qry_select_fields)
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

  def self.qry_select_fields
    kpi_fields.join(",")
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

  def self.record_hash
    columns_for_kpi.inject({}) do |hash,column|
      hash[column.name]={
        "type" => column.type
      }
      hash
    end
  end

  def self.columns_for_kpi
    columns.reject{|c| kpi_fields.include?(c.name)==false}
  end

end
