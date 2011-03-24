module ApplicationHelper
  def points(point_value)
    prefix = if point_value > 0
      "+"
    else
      ""
    end
    
    content_tag 'span', :class => 'point-value' do
      "#{prefix}#{point_value}"
    end
  end
end
