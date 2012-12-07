class Float
  def as_rounded_percentage
    (self * 100).round.to_s + "%"
  end
end
