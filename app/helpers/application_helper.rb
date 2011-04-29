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

  def default_avatar_tag(user, options={})
    alt = options[:alt]

    if alt
      image_tag user.avatar.url, :alt => alt
    else
      image_tag user.avatar.url
    end
  end

  def following_count_phrase(user)
    pluralize(user.following_count, 'person')   
  end

  def followers_count_phrase(user)
    pluralize(user.followers_count, 'fan')
  end
end
