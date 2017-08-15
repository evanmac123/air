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

  alias_method :ping_without_device_type, :ping
  alias_method :ping, :ping_with_device_type
end
