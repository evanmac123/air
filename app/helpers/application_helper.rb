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
    pluralize(user.accepted_followers.count, 'friend')
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

  def master_bar_width
    "width: #{current_user.percent_towards_next_threshold}%"
  end

  def master_bar_point_content
    "#{current_user.point_fraction} points"
  end

  def consolidated_flash
    return @consolidated_flash if @consolidated_flash

    @consolidated_flash = HashWithIndifferentAccess.new
    @_user_flashes ||= {}

    flash.each do |key, value|
      @consolidated_flash[key] = [value]
      @consolidated_flash[key] += [@_user_flashes.delete(key.to_s)]
    end

    @_user_flashes.each do |key, value|
      @consolidated_flash[key] = [value]
    end

    @consolidated_flash
  end

  def joined_flashes
    joined_content = ''
    [:success, :failure, :notice].each do |flash_key|
      single = flash[flash_key]
      next unless single.present?
      single = [single] unless single.kind_of? Array
      joined_content += single.join(' ') + ' '
    end

    if joined_content.present?
      joined_content
    else
      nil
    end
  end
end
