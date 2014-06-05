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
    new_unsubscribe_url(:host => email_link_host, :protocol => email_link_protocol, user_id: user.id, token: token).html_safe
  end

  def email_account_settings_link
    edit_account_settings_url(host: email_link_host, protocol: email_link_protocol)
  end

  def email_logo(demo)
    logo_url = demo.custom_logo_url
    image_options        = { width: "61", height: "36", border: "0", style: "display:block;"}

    if logo_url.blank?
      # Pretty asinine that we have to roll our own here. But hi. Here we are.
      expanded_logo_path = ActionController::Base.helpers.asset_path('airbo_logo_lightblue.png')
      logo_url = "#{::Rails.application.config.action_mailer.asset_host}#{expanded_logo_path}"
      image_options.merge!(alt: 'Airbo')
    else
      # They are not forced to supply alt_text; if they don't, Rails will use the filename (without extension) as the alt-text
      image_options.merge!(alt: demo.skin.alt_logo_text) unless demo.skin.alt_logo_text.blank?
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

  def link_styled_like_button(link_text, url)
    %{
      <table border="0" cellspacing="0" cellpadding="0" style='margin-bottom: 20px'>
        <tr>
          <td style="border:1px #2b8838 solid; background:#39b149;">
            <table border="0" cellspacing="0" style="background:#39b149; border-top:1px #4edf61 solid;">
              <tr>
                <td>
                  <a href = "#{url}" style="display:block; padding:2px 7px; text-decoration:none;">
                    <span style="text-decoration:none; color:#fff; font-family: Ubuntu, helvetica, arial, sans-serif; font-size:16px; font-weight:500;">#{link_text}</span>
                  </a>
                </td>
              </tr>
            </table>
          </td>
        </tr>
      </table>
    }.html_safe
  end
end
