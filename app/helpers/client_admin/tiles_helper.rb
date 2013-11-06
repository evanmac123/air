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
    message = "No digest email is scheduled to be sent because no new tiles have been added"
    message << " since the last one was sent on #{digest_email_sent_on}." unless @tile_digest_email_sent_at.nil?
    message
  end

  def email_site_link(user)
    email_link_hash = { protocol: email_link_protocol, host: email_link_host }
    email_link_hash.merge!(user_id: user.id, tile_token: EmailLink.generate_token(user)) if user.claimed? and ! user.is_client_admin

    user.claimed? ? acts_url(email_link_hash): invitation_url(user.invitation_code, email_link_hash)
  end

  def footer_timestamp(tile)
    if tile.activated_at.nil?
      "Never activated"
    elsif tile.status == Tile::ARCHIVE
      [
        "<span class='tile-active-time'>Active: ", 
        (distance_of_time_in_words tile.activated_at, tile.archived_at),
        "</span></br>",
        "<span class='tile-deactivated-time'>Deactivated: ", 
        tile.archived_at.strftime('%-m/%-d/%Y'),
        "</span>"
      ].join.html_safe
    else
      [
        "<span class='tile-active-time'>",
        "Active ", 
        (distance_of_time_in_words tile.activated_at, Time.now),
        "</span><br>",
        "<span class='tile-activated-since'>", 
        "Since ",
        tile.activated_at.strftime('%-m/%-d/%Y'),
        "</span>"
      ].join.html_safe
    end
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
