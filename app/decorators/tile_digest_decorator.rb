class TileDigestDecorator < Draper::Decorator
  decorates :tile
  delegate_all

  def email_img_url
    url = object.thumbnail(:email_digest) # Paperclip returns the full url in staging and production modes
    url.prepend('http://localhost:3000') if Rails.env.development? or Rails.env.test?
    url
  end

  def email_link_options
    context[:is_preview] ? {target: '_blank'} : {}
  end
end
