class AirboStatistics
  attr_reader :data

  def initialize(data)
    @data = DescriptiveStatistics::Stats.new(data.compact)
  end

  def data_without_outliers
    @_data_witout_outliers ||= DescriptiveStatistics::Stats.new(data.reject { |n| n < lower_outliers || n > upper_outliers })
  end

  def mean_without_outliers
    data_without_outliers.mean
  end

  def lower_outliers
    stats_base[:q1] - (1.5 * interquartile_range)
  end

  def upper_outliers
    stats_base[:q3] + (1.5 * interquartile_range)
  end

  def interquartile_range
    @_iqr ||= stats_base[:q3] - stats_base[:q1]
  end

  def stats_base
    @_stats_base ||= data.descriptive_statistics
  end
end
