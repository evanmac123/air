module MixpanelConcern
  include TrackEvent

  def invalid_ping_logger(event, data_hash, user)
    if !user && !(["sessions", "pages"].include? params[:controller])
      Rails.logger.warn "INVALID USER PING SENT #{event}"
    end
  end

  def ping_with_device_type(event, data_hash = {}, user = nil)
    _data_hash = data_hash.merge(device_type: device_type)
    ping_without_device_type(event, _data_hash, user)

    invalid_ping_logger(event, data_hash, user)
  end

  def ping_page(page, user = nil, additional_properties={})
    event = 'viewed page'
    properties = {page_name: page, device_type: device_type}.merge(additional_properties)
    self.ping(event, properties, user)
  end

  alias_method_chain :ping, :device_type

  ##Revise =>
  EMAIL_PING_TEXT_TYPES = {
    "digest_old_v" => "Digest  - v. Pre 6/13/14",
    "digest_new_v" => "Digest - v. 6/15/14",
    "follow_old_v" => "Follow-up - v. pre 6/13/14",
    "follow_new_v" => "Follow-up - v. 6/15/14",
    "explore_v_1"  => "Explore - v. 8/25/14"
  }

  def email_clicked_ping(user)
    # We rig the timestamp here so that, if this ping is present, and there's
    # also a new activity session, this ping always appears before the activity
    # session ping.
    if params[:email_type].present?
      email_ping_text = EMAIL_PING_TEXT_TYPES[params[:email_type]]
      rack_timestamp = request.env['rack.timestamp']
      event_time = (rack_timestamp || Time.now) - 5.seconds
      hsh = { email_type: email_ping_text, time: event_time }
      hsh.merge!({subject_line: params[:subject_line]}) if params[:subject_line]
      ping("Email clicked", hsh, user) if email_ping_text.present?
    end
  end
end
