module ClientAdmin::TilesHelper
  def digest_email_sent_on
    @tile_digest_email_sent_at.to_s(:tile_digest_email_sent_at)
  end

  def num_tiles_in_digest_email_message
    "A digest email containing #{pluralize @digest_tiles.size, 'tile'} is set to go out on "
  end

  def digest_email_sent_on_message
    @tile_digest_email_sent_at.nil? ? nil : "Last digest email was sent on #{@tile_digest_email_sent_at.to_s(:tile_digest_email_sent_at)}"
  end

  def no_digest_email_message
    message = "Tiles that you activate will appear here so you can share them with users in a digest email."
    message << " No new tiles have been added since the last digest email you sent on #{digest_email_sent_on}." unless @tile_digest_email_sent_at.nil?
    message
  end

  def email_site_link(user)
    email_link_hash = { protocol: email_link_protocol, host: email_link_host }
    email_link_hash.merge!(user_id: user.id, tile_token: EmailLink.generate_token(user)) if user.claimed? and ! user.is_client_admin

    user.claimed? ? acts_url(email_link_hash): invitation_url(user.invitation_code, email_link_hash)
  end

  def footer_timestamp(tile, options={})
    TileFooterTimestamper.new(tile, options).footer_timestamp
  end

  # We display a different heading if the schmuck... er, customer, didn't interact with any of the tiles in the first digest email
  def digest_email_heading_begin
    @follow_up_email ? 'Did you forget to check out your' : 'Check out your'
  end

  def digest_email_heading_end
    @follow_up_email ? '?' : '!'
  end

  def default_follow_up_day
    FollowUpDigestEmail::DEFAULT_FOLLOW_UP[Date::DAYNAMES[Date.today.wday]]
  end
end
