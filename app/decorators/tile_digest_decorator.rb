require 'addressable/uri'
class TileDigestDecorator < Draper::Decorator
  include EmailHelper
  decorates :tile
  delegate_all

  def email_img_url
    url = object.thumbnail(:email_digest) # Paperclip returns the full url in staging and production modes
    full_url = Addressable::URI.parse(url)
    full_url.scheme = email_link_protocol
    full_url.host = email_link_host
    full_url.to_s
  end

  def email_link_options
    context[:is_preview] ? {target: '_blank'} : {}
  end
end
