module ApplicationHelper
  include Mobvious::Rails::Helper

  def current_demo_id
    current_user.demo_id
  end

  def current_demo
    current_user.demo
  end

  def current_board
    current_user.demo
  end

  def current_demo_created_at
    current_demo.try(:created_at)
  end

  def get_navbar_link_class(path)
    return "active" if request.path == path
  end

  def default_avatar_tag(user, options={})
    image_tag user.avatar.url, :alt => user.name, :class => "user_avatar #{options[:class]}"
  end

  def get_user_type(user)
    if user.nil? || user.is_a?(GuestUser)
      "guest"
    elsif user.end_user?
      "user"
    elsif user.is_client_admin? || user.is_site_admin?
      "client_admin"
    end
  end

  def non_site_admin(user)
    if user.nil? || user.is_a?(GuestUser) || !user.is_site_admin
      true
    end
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

    @listified_flash
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

  def guest_for_tile_preview?
    params[:controller] == "explore/tile_previews" \
      && (current_user.nil? || current_user.is_guest?)
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

  def ie9_or_older?
    browser.ie6? || browser.ie7? || browser.ie8? || browser.ie9?
  end

  def nr_trace(name)
    result = nil

    self.class.trace_execution_scoped([name]) do
      result = yield
    end

    result
  end

  def present(object, klass = nil, opts)
    klass ||= "#{object.class}Presenter".constantize
    presenter = klass.new(object, self, opts)
    yield presenter if block_given?
    presenter
  end

  def simple_format_by_type type, val
    case type
    when "date"
      simple_date_format val
    when "mon_d_y"
      simple_date_mon_d_yyyy val
    when "money"
      simple_money_format val
    when "pct"
      "#{simple_percentage_format(val, {precision: 2} )}"
    when "pct 0"
      "#{simple_percentage_format(val, { precision: 0}) }"
    else
      val
    end
  end

  def simple_date_format date
    date.try(:strftime, "%m/%d/%Y")
  end

  def simple_date_format_Y_d_m date, sep="-"
    date.try(:strftime, "%Y#{sep}%m#{sep}%d")
  end

  def simple_date_mon_d_yyyy date
    date.try(:strftime, "%b %d, %Y")
  end

  def simple_money_format amt
   number_to_currency amt, precision:0
  end

  def simple_number_format num
    number_with_delimiter num.to_i
  end

  def simple_percentage_format num, opts={}
    opts.merge!({strip_insignificant_zeros:true})
    number_to_percentage(num, opts)
  end

  def unescape_html html
    coder = HTMLEntities.new
    raw coder.decode("" + html + "")
  end

  def dependent_board_email_subject
    current_user.demo.dependent_board_email_subject || DEFAULT_INVITE_DEPENDENT_SUBJECT_LINE
  end

  def dependent_board_email_body
    current_user.demo.dependent_board_email_body || DEFAULT_INVITE_DEPENDENT_EMAIL_BODY
  end

  def copy_to_clipboard_class(enabled:)
    unless enabled
      "copy-disabled"
    end
  end
end
