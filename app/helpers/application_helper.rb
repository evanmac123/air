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

  def default_avatar_tag(options={})
    alt = options[:alt]

    if alt
      image_tag 'default_avatar.png', :alt => alt
    else
      image_tag 'default_avatar.png'
    end
  end
end
