module ClientAdmin::PrizesHelper
  def date_in_pick_format date
    if date.present?
      date.strftime("%m/%d/%Y")
    else
      nil
    end
  end

  def time_left time_params
    starts_at = time_params[:starts_at]
    ends_at   = time_params[:ends_at]
    position  = time_params[:position]
    format    = time_params[:format]

    unless starts_at.present? && ends_at.present?
      dimention = (position == :first ? "week" : "day")
      return time_in_format 0, format, dimention 
    end
    #choose duration from today or future start date
    duration = ends_at + 1.minute - starts_at

    if duration < 0
      dimention = (position == :first ? "week" : "day")
      return time_in_format 0, format, dimention 
    end

    dimention, duration = find_dimention_and_convert_duration duration, position

    time_in_format duration, format, dimention
  end

  #choose dimention to measure time and converts to it
  def find_dimention_and_convert_duration duration, position
    if    (duration > 1.week && position == :first)
      ["week", convert_duration(duration, position, "week")]
    elsif (duration > 1.week && position == :second) || \
          (duration > 1.day && position == :first)
      ["day", convert_duration(duration, position, "day")]
    elsif (duration >= 1.day && position == :second) || \
          (duration <= 1.day && position == :first) 
      ["hour", convert_duration(duration, position, "hour")]
    elsif (duration <= 1.day && position == :second)
      ["minute", convert_duration(duration, position, "minute")]
    end
  end

  def convert_duration duration, position, dimention
    if dimention == "week"
      (duration / (60 * 60 * 24 * 7)).to_i
    elsif dimention == "day" && position == :first
      (duration / (60 * 60 * 24)).to_i
    elsif dimention == "day" && position == :second
      (duration / (60 * 60 * 24)).to_i - (duration / (60 * 60 * 24 * 7)).to_i * 7
    elsif dimention == "hour" && position == :first
      (duration / (60 * 60)).to_i
    elsif dimention == "hour" && position == :second
      (duration / (60 * 60)).to_i - (duration / (60 * 60 * 24)).to_i * 24
    elsif dimention == "minute" && position == :second
      (duration / (60)).to_i - (duration / (60 * 60)).to_i * 60
    end
  end

  def time_in_format duration, format, dimention
    if format == :number
      duration
    else
      dimention.pluralize(duration)
    end
  end

  def winner_email_subject
    "Congratulations - you're an Airbo prize winner!"
  end

  def winner_email_body
    "Congratulations! You're an Airbo prize winner." +
    " Thanks for participating and be sure to watch for new tiles to be posted soon."
  end
end
