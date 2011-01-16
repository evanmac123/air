module ApplicationHelper
  def points(rule)
    prefix = if rule.points > 0
      "+"
    else
      ""
    end
    "#{prefix}#{rule.points}"
  end
end
