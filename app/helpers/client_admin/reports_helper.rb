module ClientAdmin::ReportsHelper
  def report_default_start_date
    if demo_launch > 3.months.ago
      demo_launch
    else
      Time.now.end_of_month - 3.months
    end
  end

  def reportings_date_switch_opts
    [
      past_three_months,
      past_twelve_months,
      all_time_or_last_five_years,
      last_four_years
    ].flatten.compact
  end

  private

    def demo_launch
      if current_demo.launch_date
        current_demo.launch_date.try(:to_time).beginning_of_year
      else
        current_demo.created_at.beginning_of_year
      end
    end

    def past_three_months
      if (Time.now - demo_launch) > 3.months
        {
          formatted_name: "Past 3 Months",
          start_date: Time.now.end_of_month - 3.months,
          end_date: Time.now,
        }
      end
    end

    def past_twelve_months
      if (Time.now - demo_launch) > 12.months
        {
          formatted_name: "Past 12 Months",
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
      unless demo_launch.year == Time.now.year
        [*demo_launch.year..Time.now.year].reverse.map { |year|
          {
            formatted_name: "#{year}",
            start_active: false,
            start_date: Time.new(year),
            end_date: Time.new(year).end_of_year,
          }
        }.take(4)
      end
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
