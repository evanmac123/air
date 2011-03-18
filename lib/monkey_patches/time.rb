class Time
  def winning_time_format
    self.in_time_zone('Eastern Time (US & Canada)').strftime("%B %d, %Y at %I:%M %p Eastern")
  end

  def with_us
    # 1.8.7 doesn't recognize %N directive for fractional part of seconds, and
    # we're running REE 1.8.7 in production & staging
    result = strftime("%Y-%m-%d %H:%M:%S.")
    result += usec.to_s
    result += strftime(" %Z")
  end
end
