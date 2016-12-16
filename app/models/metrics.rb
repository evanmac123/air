class Metrics < ActiveRecord::Base
  WEEKLY="weekly"
  MONTHLY="monthly"

  def self.by_date_range_and_interval sdate, edate, interval=WEEKLY
    by_interval(interval).by_start_and_end(sdate, edate).order("from_date asc")
  end

  def self.by_interval(interval = WEEKLY)
    where(interval: interval)
  end

  def self.by_start_and_end sdate, edate
    where(["from_date >= ? and to_date <= ?",sdate, edate])
  end

end
