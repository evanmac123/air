module EmailHelper
  def accept_friendship_url(user_id, friendship_id)
    accept_user_friendship_url user_id:       user_id,
                               friendship_id: friendship_id,
                               host:          email_link_host,
                               protocol:      email_link_protocol,
                               token:         EmailLink.generate_token(Friendship.find friendship_id)
  end

  def email_unsubscribe_link(user)
    token = EmailLink.generate_token(user)
    new_unsubscribe_url(:host => email_link_host, :protocol => email_link_protocol, user_id: user.id, token: token)
  end

  def email_account_settings_link
    edit_account_settings_url(host: email_link_host, protocol: email_link_protocol)
  end

  def email_link_host
    if Rails.env.production? 
      "www.hengage.com"
    elsif Rails.env.staging?
      "www.hengagestaging.com"
    elsif Rails.env.development?
      "localhost:3000"
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
