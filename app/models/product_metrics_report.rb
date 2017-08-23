class ProductMetricsReport < ActiveRecord::Base
  as_enum :period, week: 0, month: 1

  def self.set_demo_tile_health_reports
    Demo.paid.each do |demo|
      Rails.cache.delete(Demo.tile_engagement_health_report_cache_key(demo))
      demo.tile_engagement_health_report
    end
  end

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
