class ProductMetricsReport < ActiveRecord::Base
  as_enum :period, week: 0, month: 1

  def date_range
    from_date..to_date
  end

  def mp_from_date
    from_date.strftime("%Y-%m-%d")
  end

  def mp_to_date
    to_date.strftime("%Y-%m-%d")
  end
end
