require 'addressable/uri'
class TileDigestDecorator < Draper::Decorator
  include EmailHelper
  decorates :tile
  delegate_all

  def email_img_url
    url = object.thumbnail(:email_digest) # Paperclip returns the full url in staging and production modes
    full_url = Addressable::URI.parse(url)
    full_url.scheme = email_link_protocol unless full_url.scheme
    full_url.host = email_link_host unless full_url.host
    full_url.to_s
  end

  def email_link_options
    context[:is_preview] ? {target: '_blank'} : {}
  end
end
