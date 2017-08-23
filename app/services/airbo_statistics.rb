class AirboStatistics
  attr_reader :data

  def initialize(data:)
    @data = DescriptiveStatistics::Stats.new(data.compact)
  end

  def dataset_without_outliers
    @_dataset_witout_outliers ||= set_dataset_without_outliers
  end

  def set_dataset_without_outliers
    d = data.reject { |n| n < lower_outlier_threshold || n > upper_outlier_threshold }
    AirboStatistics.new(data: d)
  end

  def lower_outlier_threshold
    stats_base[:q1] - (1.5 * interquartile_range)
  end

  def upper_outlier_threshold
    stats_base[:q3] + (1.5 * interquartile_range)
  end

  def interquartile_range
    @_iqr ||= stats_base[:q3] - stats_base[:q1]
  end

  def stats_base
    @_stats_base ||= data.descriptive_statistics
  end
end
