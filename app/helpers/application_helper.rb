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

  def add_byte_counter_for(field_label)
    content_for :javascript do
      javascript_tag <<-END_JAVASCRIPT
        (function(){
          var label = $('label:contains(#{field_label})').first();
          var field_id = '#' + label.attr('for');
          addByteCounterFor(field_id);
        })()
      END_JAVASCRIPT
    end
  end

  def navbar_link_to(link_text, path, options={})
    last = options.delete(:last)

    output = link_to(link_text, path, options)
    unless last
      output += image_tag('new_activity/navbar_separator.png', :class => 'navbar-separator')
    end

    output
  end
end
