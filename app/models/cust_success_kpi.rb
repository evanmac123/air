class CustSuccessKpi < ActiveRecord::Base

  def self.normalized_by_start_and_end sdate, edate
    by_start_and_end(sdate, edate).order("weekending_date asc")
  end

  def self.by_start_and_end sdate, edate
    where(["weekending_date >= ? and weekending_date < ?",sdate, edate])
  end

end
