module ApplicationHelper
  def points(act)
    prefix = if act.rule.points > 0
      "+"
    else
      ""
    end
    prefix + act.rule.points.to_s + " points"
  end
end
