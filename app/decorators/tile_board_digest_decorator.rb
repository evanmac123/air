class TileBoardDigestDecorator < Draper::Decorator
  decorates :tile
  delegate_all

  def email_img_url
    url = object.thumbnail(:email_digest) # Paperclip returns the full url in staging and production modes
    url.prepend('http://localhost:3000') if Rails.env.development? or Rails.env.test?
    url
  end

  def email_site_link
    h.email_site_link(context[:user], 
                      context[:demo], 
                      context[:is_preview] ||= false, 
                      context[:email_type])
  end

  def email_link_options
    context[:is_preview] ? {target: '_blank'} : {}
  end
end
