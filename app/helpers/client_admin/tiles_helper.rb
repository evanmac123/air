module ClientAdmin::TilesHelper

  def num_tiles_in_digest_email
    "A digest email containing #{@num_tiles_in_digest_email} newly-added tiles is set to go out on "
  end

  def tile_digest_email_sent_at
    "Last sent on #{@tile_digest_email_sent_at.to_s(:tile_digest_email_sent_at)}"
  end

end
