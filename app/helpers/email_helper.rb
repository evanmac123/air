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
  # In staging and production modes the full image-url (to Amazon S3) will be generated for us. (I hope.)
  #
  # In development and test modes this does not happen => will just see the 'alt text' instead. This is because you just
  # get 'assets/logo.png' and since this is in a static email there is no server which can correctly grab assets/images.
  #
  def email_logo(demo)
    # 'skinned_for_demo' checks for a skin being defined => can tell from its output whether or not a skin exists for this demo
    hengage_logo = 'logo.png'
    logo = skinned_for_demo(demo, 'logo_url', hengage_logo)
    alt_text = (logo == hengage_logo) ? 'H.Engage' : demo.skin.alt_logo_text

    # Skin may not have defined 'alt_logo_text' => don't include 'alt' attribute if not defined so at least get something displayed
    # From Rails doc: If no alt text is given, the file name part of the source is used (capitalized and without the extension)
    image_options = { width: "150px", style: "display:block;" }
    image_options.merge!(alt: alt_text) unless alt_text.blank?

    image_tag logo, image_options
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
