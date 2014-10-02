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

  def listified_flash
    return @listified_flash if @listified_flash

    @listified_flash = HashWithIndifferentAccess.new

    flash.each do |key, value|
      @listified_flash[key] = [value]
    end
    
    add_persistent_message!(@listified_flash)
    @listified_flash
  end

  def add_persistent_message!(listified_flash)
    return unless use_persistent_message?

    keys_for_real_flashes = %w(success failure notice)
    return if keys_for_real_flashes.any?{|key| listified_flash[key].present?}

    message_from_board = current_user.try(:demo).try(:persistent_message)
    success_message = if message_from_board.present?
                        message_from_board
                      else
                        default_persistent_message
                      end

    listified_flash[:success] = [success_message]
  end

  def default_persistent_message
    "Airbo is an interactive communication tool. Read information and answer questions on the tiles to earn points."
  end
 
  def use_persistent_message?
    # UGH. But I haven't found a better way yet to override helpers on a
    # controller-by-controller basis.
    params['controller'] == 'acts' && params['action'] == 'index'
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

  def set_home_path public_tile_page
    if public_tile_page
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

  def js_at_end(&block)
    content_for :javascript do
      javascript_tag do
        yield
      end
    end
  end
end
