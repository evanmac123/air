module EmailHelper
  def accept_friendship_url(user_id, friendship_id)
    accept_user_friendship_url user_id:       user_id,
                               friendship_id: friendship_id,
                               host:          email_link_host,
                               protocol:      email_link_protocol,
                               token:         EmailLink.generate_token(Friendship.find friendship_id)
  end

  def email_friend_url friend, user
    token = EmailLink.generate_token(user)
    user_url(friend, user_id: user.id, token: token)
  end 

  def email_unsubscribe_link(user)
    token = EmailLink.generate_token(user)
    new_unsubscribe_url(:host => email_link_host, :protocol => email_link_protocol, user_id: user.id, token: token).html_safe
  end

  def email_account_settings_link
    edit_account_settings_url(host: email_link_host, protocol: email_link_protocol)
  end

  def email_logo(demo)
    image_options = { border: "0", style: "display:block;max-width:90px;"}
    if demo.logo_file_name.blank?
      # Pretty asinine that we have to roll our own here. But hi. Here we are.
      expanded_logo_path = ActionController::Base.helpers.asset_path('airbo_logo_lightblue.png')
      logo_url = "#{::Rails.application.config.action_mailer.asset_host}#{expanded_logo_path}"
      image_options.merge!(alt: 'Airbo')
    else
      logo_url = demo.logo.url
    end

    image_tag logo_url, image_options
  end

  # Had to define environment variables on Heroku so that SendGrid sends emails to the right place in staging and production
  # In staging this will be: 'www.hengagestaging.com' while in production it's: 'www.hengage.com'
  def email_link_host
    if Rails.env.development?
      "localhost:3000"
    elsif Rails.env.test?
      "example.com"
    else
      ENV["EMAIL_HOST"]
    end
  end

  # Had to define environment variables on Heroku so that SendGrid sends emails to the right place in staging and production
  # This will be 'https' in staging and production
  def email_link_protocol
    ENV["EMAIL_PROTOCOL"] or 'http'
  end
end
