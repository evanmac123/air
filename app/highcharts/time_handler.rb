class TimeHandler
  # INTERVAL_TYPES = ['monthly', 'weekly', 'daily', 'hourly'].freeze

  DATE_RANGE_TYPES = {
    'past_week'         => {text: "Past week",      duration: 1.week},
    'past_30_days'      => {text: "Past 30 days",   duration: 30.days},
    "past_3_months"     => {text: "Past 3 months",  duration: 3.months},
    "past_12_months"    => {text: "Past 12 months", duration: 12.months},
    "pick_a_date_range" => {text: "Pick a date range..."}
  }.freeze

  attr_accessor :interval_type, :start_date, :end_date, :date_range_type, :changed_field

  def initialize params
    @interval_type, @start_date, @end_date, @date_range_type, @changed_field =
      params.values_at(:interval_type, :start_date, :end_date, :date_range_type, :changed_field)
  end

  def handle
    case changed_field
    when "date_range_type"
      handle_date_range
    when "start_date"
      handle_date_picker start_date
    when "end_date"
      handle_date_picker end_date
    end
    self
  end

  def date_range_types_disabled_option
    to_american_long_format(start_date) + " - " + to_american_long_format(end_date)
  end

  def date_range_types_select_list
    [[date_range_types_disabled_option] * 2] +
    DATE_RANGE_TYPES.keys.collect{ |key| [ DATE_RANGE_TYPES[key][:text], key ] }
  end

  def show_dates_selection
    show_date_selection? ? "block" : "none"
  end

  def show_date_range
    show_date_selection? ? "none" : "block"
  end

  protected
    def show_date_selection?
      date_range_type == "pick_a_date_range"
    end

    def handle_date_range
      self.end_date = to_american_format Time.now
      self.start_date = to_american_format(Time.now - DATE_RANGE_TYPES[date_range_type][:duration])

      handle_interval_type
    end

    def handle_date_picker changed_date
      start_time = from_american_format(start_date)
      end_time = from_american_format(end_date)
      if start_time >= end_time
        self.start_date = self.end_date = changed_date
      end

      handle_interval_type
    end

    def to_american_format time
      time.strftime("%b %d, %Y")
    end

    def from_american_format str
      Time.strptime(str, "%b %d, %Y")
    end

    def to_american_long_format str
      from_american_format(str).strftime("%b %d, %Y")
    end

    def handle_interval_type
      date_diff = from_american_format(end_date) - from_american_format(start_date)
      self.interval_type = if date_diff <= 24.hours
                            'hourly'
                          elsif date_diff <= 30.days
                            'daily'
                          elsif date_diff <= 2.months
                            'weekly'
                          else
                            'monthly'
                          end
    end
end
