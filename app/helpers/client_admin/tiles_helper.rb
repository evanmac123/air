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
    message << " since the last one was sent on #{digest_email_sent_on}" unless @tile_digest_email_sent_at.nil?
    message
  end

  # Decided not to give this initial value of 'Never' => Also need to check if 'nil'
  def send_on_time
    content_tag :span, (@tile_digest_email_send_on.nil? or @tile_digest_email_send_on == 'Never') ? nil : 'at noon, ', id: 'digest-send-on-time'
  end

  def shelf_life(tile)
    case
      when tile.start_time.nil? && tile.end_time.nil? then "Forever"
      when tile.start_time      && tile.end_time.nil? then "#{tile.start_time.to_s(:tile_digest_email_shelf_life)} - Forever"
      when tile.start_time      && tile.end_time      then "#{tile.start_time.to_s(:tile_digest_email_shelf_life)} - #{tile.end_time.to_s(:tile_digest_email_shelf_life)}"
    end
  end
end
