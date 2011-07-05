class Time
  def winning_time_format
    self.strftime("%B %d, %Y at %I:%M %p Eastern")
  end

  # Pretend that lowercase "u" is a Greek "mu", we're talking with_microseconds here.

  def with_us
    # 1.8.7 doesn't recognize %N directive for fractional part of seconds, and
    # we're running REE 1.8.7 in production & staging

    with_fractional_second_part(usec)
  end

  def with_ms
    with_fractional_second_part(usec / 1000)
  end

  private

  def with_fractional_second_part(fraction)
    [
      strftime("%Y-%m-%d %H:%M:%S."),
      fraction.to_s,
      strftime(" %Z")
    ].join('')
  end
end
