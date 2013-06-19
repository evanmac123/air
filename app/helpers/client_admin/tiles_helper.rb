module ClientAdmin::TilesHelper

  def digest_email_sent_on
    @tile_digest_email_sent_at.to_s(:tile_digest_email_sent_at)
  end

  def num_tiles_in_digest_email_message
    "A digest email containing #{pluralize @digest_tiles.size, 'tile'} is set to go out on "
  end

  def digest_email_sent_on_message
    "Last digest email was sent on #{@tile_digest_email_sent_at.to_s(:tile_digest_email_sent_at)}"
  end

  def no_digest_email_message
    message = "No digest email is scheduled to be sent because no new tiles have been added"
    message << " since the last one was sent on #{digest_email_sent_on}." unless @tile_digest_email_sent_at.nil?
    message
  end

  # Decided not to give this initial value of 'Never' => Also need to check if 'nil'
  def send_on_time
    content_tag :span, (@tile_digest_email_send_on.nil? or @tile_digest_email_send_on == 'Never') ? nil : 'at noon, ', id: 'digest-send-on-time'
  end

  def email_site_link(user)
    email_link_hash = { protocol: email_link_protocol, host: email_link_host }
    user.claimed? ? acts_url(email_link_hash): invitation_url(user.invitation_code, email_link_hash)
  end
end
