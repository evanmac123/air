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

  # If the customer wants their own logo the full url will be in the 'skins' table and we will use that.
  # If not, we use our logo, which is served out of the 'assets/images' directory.
  #
  # For H.Engage, 'image_tag' spits out '/assets/logo.png' in Dev and Test modes, and something like
  # 'assets/logo-580aed6750f34956244a346b8f34fa73.png' in Staging and Production.
  #
  # This means we won't see the logo in Dev and Test mode (because the path is wrong) - but we don't need to.
  #
  def email_logo(demo)
    hengage_logo         = 'logo.png'
    image_options        = { width: "150px", style: "display:block;" }
    hengage_asset_server = "https://hengage-assets.s3.amazonaws.com"

    # 'skinned_for_demo' checks for a skin being defined => can tell from its output whether or not a skin exists for this demo
    logo = skinned_for_demo(demo, 'logo_url', hengage_logo)

    if logo == hengage_logo
      image_options.merge!(alt: 'H.Engage')
    else
      # They are not forced to supply alt_text; if they don't, Rails will use the filename (without extension) as the alt-text
      image_options.merge!(alt: demo.skin.alt_logo_text) unless demo.skin.alt_logo_text.blank?
    end

    url = image_tag logo, image_options
    url.insert(url.index('/assets'), hengage_asset_server) if logo == hengage_logo

    url
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
