module MixpanelConcern
  include TrackEvent

  def invalid_ping_logger(event, _data_hash, user)
    if !user && !(["sessions", "pages"].include? params[:controller])
      Rails.logger.warn "INVALID USER PING SENT #{event}"
    end
  end

  def ping_with_device_type(event, data_hash = {}, user = nil)
    data_hash_with_device = data_hash.merge(device_type: device_type)
    ping_without_device_type(event, data_hash_with_device, user)

    invalid_ping_logger(event, data_hash, user)
  end

  def ping_page(page, user = nil, additional_properties={})
    event = 'viewed page'
    properties = {page_name: page, device_type: device_type}.merge(additional_properties)
    self.ping(event, properties, user)
  end

  alias_method_chain :ping, :device_type

  def email_clicked_ping(user)
    if params[:email_type].present?
      email_ping_text = BaseTilesDigestMailer.digest_types_for_mixpanel[params[:email_type]]
      rack_timestamp = request.env['rack.timestamp']
      event_time = (rack_timestamp || Time.now) - 5.seconds
      hsh = { email_type: email_ping_text, time: event_time }
      hsh.merge!({subject_line: params[:subject_line]}) if params[:subject_line]
      ping("Email clicked", hsh, user) if email_ping_text.present?
    end
  end
end
