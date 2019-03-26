class Time
  def pretty(timezone = 'Eastern')
    self.strftime("%B %d, %Y at %I:%M %p #{timezone.split(' ').first}")
  end

  def pretty_succinct
    self.strftime("%b %d, %Y @ %I:%M %p")
  end
end
