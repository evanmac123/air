module ApplicationHelper
  include Mobvious::Rails::Helper

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

  def starting_points
    flash[:previous_points].try(:to_i) || current_user.points
  end

  def starting_tickets
    flash[:previous_tickets].try(:to_i) || current_user.tickets
  end

  def raffle_progress_bar
    current_user.to_ticket_progress_calculator.points_towards_next_threshold
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
      @consolidated_flash[key] ||= []
      @consolidated_flash[key] += [value]
    end

    @consolidated_flash = display_flashes_from_last_time if @consolidated_flash.empty?
    @consolidated_flash
  end

  def display_flashes_from_last_time
    # If no new flashes have been created to display, display the saved flashes
    # that were stored as cookies in ApplicationController#keep_flashes_for_next_time
    hash = HashWithIndifferentAccess.new 
    saved_success = :saved_flash_success
    saved_failure = :saved_flash_failure
    hash[:success] = [cookies[saved_success]] if cookies[saved_success].try(:present?)
    hash[:failure] = [cookies[saved_failure]] if cookies[saved_failure].try(:present?)
    hash
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
      # Want the following error message to be in red. However, making all status messages red
      # didn't look right elsewhere (really can't remember where), so just do it for a bad login attempt.
      joined_content = content_tag(:span, joined_content, class: 'red_text') if joined_content =~ /invalid username or password/
      joined_content
    else
      nil
    end
  end

  def characteristic_input_specifiers_as_json(characteristics)
    characteristic_information_as_json(characteristics, :input_specifier)
  end

  def characteristic_allowed_operators_as_json(characteristics)
    characteristic_information_as_json(characteristics, :allowed_operator_names)
  end

  def characteristic_information_as_json(characteristics, method_name)
    Hash[characteristics.map {|characteristic| [characteristic.id.to_s, characteristic.send(method_name)]}].to_json.html_safe
  end

  def raw_allowed_in_flash?(flash_key)
    ApplicationController::FLASHES_ALLOWING_RAW.include?(flash_key.to_s) || flash[(flash_key.to_s + "_allow_raw").to_sym]
  end

  def is_mobile?
    request.env['mobvious.device_type'] == :mobile
  end

  def is_tablet?
    request.env['mobvious.device_type'] == :tablet
  end

  def is_desktop?
    request.env['mobvious.device_type'] == :desktop
  end

  def show_save_progress_button
    current_user.try(:is_guest?)
  end

  def done_all_tiles_message
    if @no_tiles_to_do
      "There aren't any tiles available at this time. Check back later for more."
    else
      "You've completed all available tiles! Check back later for more."
    end
  end

  def tile_thumbnail_target(tile, selected_tag_id = nil)
    # It would have been much neater to deal with this via inheritance.
    # Too bad you can't inherit views, and doing it with helpers didn't seem
    # to, as it were, help.
    #
    # So instead we get this hack:
    if params[:controller] == 'explores'
      explore_tile_preview_path(tile, tag_id: selected_tag_id)
    else
      params[:public_slug] ? public_tile_path(params[:public_slug], tile) : tile_path(tile)
    end
  end

  def set_home_path params
    if params[:public_tile_page]
      "/"
    elsif guest_for_tile_preview?
      nil
    elsif current_user.is_guest?
      public_activity_path(current_user.demo.public_slug)
    else
      activity_path
    end
  end

  def guest_for_tile_preview?
    params[:controller] == "tile_previews" \
      && (current_user.nil? || current_user.is_guest?)
  end

  def user_is_guest_for_tile_preview?
    params[:controller] == "tile_previews" \
      && !current_user.is_client_admin && !current_user.is_site_admin
  end

  def set_new_board_url
    if Rails.env.production?
      boards_url(protocol: 'https', host: hostname_with_subdomain)
    else
      boards_url
    end
  end

  def hostname_with_subdomain
    request.subdomain.present? ? request.host : "www." + request.host
  end
end
