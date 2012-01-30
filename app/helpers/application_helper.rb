module ApplicationHelper
  def default_avatar_tag(user, options={})
    image_tag user.avatar.url, :alt => user.name, :class => "user_avatar #{options[:class]}"
  end

  def avatar_96(user)
    content_tag("div", :class => 'avatar_image') do
      default_avatar_tag(user, :class => "size-96")
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
      options[:class] += "active"
    end

    output = content_tag('li', options) {link_to(link_text, path)}

    output
  end

  def master_bar_width
    "width: #{current_user.percent_towards_next_threshold}%"
  end

  def master_bar_point_content
    points = current_user.points_towards_next_threshold
    point_denominator = current_user.point_threshold_spread
    "#{points}/#{point_denominator} points"
  end

  def joined_flashes
    joined_content = ''
    [:success, :failure, :notice].each do |flash_key|
      next unless flash[flash_key].present?
      joined_content += flash[flash_key] + ' '
    end

    if joined_content.present?
      joined_content
    else
      nil
    end
  end
end
