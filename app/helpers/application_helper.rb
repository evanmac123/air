module ApplicationHelper
  def points(rule)
    prefix = if rule.points > 0
      "+"
    else
      ""
    end
    
    content_tag 'span', :class => 'point-value' do
      "#{prefix}#{rule.points}"
    end
  end
end
