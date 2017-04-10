module ClientAdmin::ReportsHelper
  def report_default_start_date
    if demo_launch > 1.year.ago
      demo_launch
    else
      1.year.ago
    end
  end

  def reportings_date_switch_opts
    [
      past_twelve_months,
      all_time_or_last_five_years,
      last_four_years
    ].flatten.compact
  end

  private

    def demo_launch
      current_demo.created_at
    end

    def past_twelve_months
      if (Time.now - demo_launch) > 12.months
        {
          formatted_name: "Past 12 Months",
          start_active: true,
          start_date: Time.now - 1.year,
          end_date: Time.now,
        }
      end
    end

    def all_time_or_last_five_years
      if five_years_or_older?
        five_years
      else
        all_time
      end
    end

    def five_years
      {
        formatted_name: "Past Five Years",
        start_active: false,
        start_date: launch_date_or_five_years,
        end_date: Time.now,
      }
    end

    def all_time
      {
        formatted_name: "All Time",
        start_active: all_time_start_active?,
        start_date: launch_date_or_five_years,
        end_date: Time.now,
      }
    end

    def last_four_years
      [*demo_launch.year..(Time.now - 1.year).year].reverse.map { |year|
        {
          formatted_name: "#{year}",
          start_active: false,
          start_date: Time.new(year),
          end_date: Time.new(year).end_of_year,
        }
      }.take(4)
    end

    def launch_date_or_five_years
      if five_years_or_older?
        1825.days.ago
      else
        demo_launch
      end
    end

    def five_years_or_older?
      demo_launch < (Time.now - 1825.days)
    end

    def all_time_start_active?
      past_twelve_months ? false : true
    end
end
