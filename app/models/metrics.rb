class Metrics < ActiveRecord::Base
  WEEKLY="weekly"
  MONTHLY="monthly"

  def self.normalized_by_date_range_and_interval sdate, edate, interval="weekly"
       by_interval(interval).by_start_and_end(sdate, edate).order("from_date asc")
  end

  def self.by_interval(interval = WEEKLY)
    where(interval: interval)
  end

  def self.current_week
    by_start_and_end(*default_date_range)
  end

  def self.current_week_with_date_range
    [by_start_and_end(*default_date_range),@sweek, @this_week]
  end

  def self.by_start_and_end sdate, edate
    where(["from_date >= ? and to_date <= ?",sdate, edate])
  end

  def self.default_date_range
    @this_week =Date.today.beginning_of_week
    @sweek = @this_week.advance(weeks: -5)
    [@sweek, @this_week]
  end

  def self.results
    select(qry_select_fields)
  end


  def self.qry_select_fields
    FinancialsReporterService.query_select_fields
  end
end
