module EmailHelper
  def email_unsubscribe_link(user)
    token = Unsubscribe.generate_token(user) 
    new_unsubscribe_url(:host => email_link_host, :protocol => email_link_protocol, user_id: user.id, token: token)
  end

  def email_account_settings_link
    edit_account_settings_url(host: email_link_host, protocol: email_link_protocol)
  end


  def email_link_host
    if Rails.env.production? 
      "hengage.com"
    elsif Rails.env.staging?
      "hengagestaging.com"
    elsif Rails.env.development?
      "localhost"
    else
      "example.com"
    end
  end

  def email_link_protocol
    if Rails.env.production? || Rails.env.staging?
      'https'
    else
      'http'
    end
  end
end
