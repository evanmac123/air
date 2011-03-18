class Time
  def winning_time_format
    self.in_time_zone('Eastern Time (US & Canada)').strftime("%B %d, %Y at %I:%M %p Eastern")
  end

  def with_us
    strftime("%Y-%m-%d %H:%M:%S.%6N %Z")
  end
end
