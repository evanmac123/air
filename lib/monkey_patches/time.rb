class Time
  def pretty
    self.strftime("%B %d, %Y at %I:%M %p Eastern")
  end
  
  def pretty_succinct
    self.strftime("%b %d, %Y @ %I:%M %p")
  end
end
