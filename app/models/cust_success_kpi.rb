class CustSuccessKpi < ActiveRecord::Base


  def self.normalized_by_start_and_end sdate, edate
    by_start_and_end(sdate, edate).order("weekending_date asc").to_array_of_record_hashes
  end


  def self.by_start_and_end sdate, edate
    where(["weekending_date >= ? and weekending_date < ?",sdate, edate])
  end


  def self.to_array_of_record_hashes
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
    Reporting::ClientKPIReport.new.query_select_fields
  end

end
