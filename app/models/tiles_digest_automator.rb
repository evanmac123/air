class TilesDigestAutomator < ActiveRecord::Base
  belongs_to :demo
  validates :demo, presence: true
  validates :day, presence: true
  validates :time, presence: true
  validates :frequency_cd, presence: true
  validates :deliver_date, presence: true

  as_enum :frequency, daily: 0, weekly: 1, biweekly: 2, monthly: 3

  before_destroy :remove_job

  def set_deliver_date
    self.deliver_date = next_deliver_time
  end

  def reset_deliver_date
    self.deliver_date = next_deliver_time(origin_for_reset)
  end

  def origin_for_reset
    case frequency
    when :weekly
      Time.current - 1.week
    when :biweekly
      Time.current - 2.weeks
    else
      Time.current
    end
  end

  def update_deliver_date
    set_deliver_date
    self.save
  end

  def schedule_delivery
    remove_job
    new_job = delay(run_at: deliver_date, queue: "TilesDigestAutomation").deliver
    self.update_attributes(job_id: new_job.id)
  end

  def deliver
    deliver_digest
    update_deliver_date
    schedule_delivery
  end

  def remove_job
    job.destroy if job
  end

  def job
    Delayed::Job.where(id: job_id).first
  end

  def deliver_digest
    return unless demo.digest_tiles.present?
    form = TilesDigestForm.new(demo: demo, params: tiles_digest_params)
    form.submit_schedule_digest_and_followup
  end

  def next_deliver_time(origin = current_deliver_date)
    date = next_deliver_date(origin)
    date.in_time_zone(demo.timezone).change(hour: time)
  end

  def current_deliver_date
    deliver_date || demo.tile_digest_email_sent_at || Time.current
  end

  private

    def tiles_digest_params
      current_draft = demo.get_tile_email_draft

      if current_draft.present?
        current_draft
      else
        {
          demo_id: demo.id,
          digest_send_to: include_unclaimed_users,
          follow_up_day: get_follow_up_day,
          include_sms: include_sms,
          custom_subject: demo.digest_tiles.first.try(:headline)
        }
      end
    end

    def get_follow_up_day
      if has_follow_up && !daily?
        follow_up_day = (day + 3) % 7
        Date::DAYNAMES[follow_up_day]
      else
        "Never"
      end
    end

    def next_deliver_date(origin)
      deliver_date = get_next_date(origin)

      if deliver_date > Time.zone.today.end_of_day
        deliver_date
      else
        next_deliver_date(deliver_date)
      end
    end

    def get_next_date(origin)
      case frequency
      when :daily
        next_date_for_daily(origin)
      when :weekly
        next_date_for_weekly(origin, 1.week)
      when :biweekly
        next_date_for_weekly(origin, 2.weeks)
      when :monthly
        next_date_for_monthly(origin)
      end
    end

    def next_date_for_daily(origin)
      origin + 1.day
    end

    def next_date_for_weekly(origin, unit)
      next_date_on_day(origin) + unit
    end

    def next_date_on_day(origin)
      until origin.wday == day
        origin += 1.day
      end

      origin
    end

    def next_date_for_monthly(origin)
      first_day_of_month = (origin + 1.month).beginning_of_month
      next_date_on_day(first_day_of_month)
    end
end
