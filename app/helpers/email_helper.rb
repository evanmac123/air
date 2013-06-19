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
