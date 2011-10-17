module ApplicationHelper
  def default_avatar_tag(user, options={})
    alt = options[:alt]

    if alt
      image_tag user.avatar.url, :alt => alt
    else
      image_tag user.avatar.url
    end
  end

  def following_count_phrase(user)
    pluralize(user.accepted_friends.count, 'person')   
  end

  def followers_count_phrase(user)
    pluralize(user.accepted_followers.count, 'fan')
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

    if link_text == @current_link_text
      options[:class] ||= ""
      options[:class] += "current-section"
    end

    output = link_to(link_text, path, options)
    unless last
      output += image_tag('new_activity/navbar_separator.png', :class => 'navbar-separator')
    end

    output
  end
end
