module TilesDigestAutomatorHelper
  def tiles_digest_automator_save(object)
    if object.persisted?
      "Update"
    else
      "Save"
    end
  end

  def tiles_digest_automate_time_opts
    [*5..21].map do |t|
      if t > 12
        display = "at #{t - 12}pm"
      elsif t == 12
        display = "at 12pm"
      else
        display = "at #{t}am"
      end

      [display, t.to_s]
    end
  end

  def tiles_digest_last_sent_or_scheduled_message
    if current_board.tiles_digest_automator.present?
      tiles_digest_scheduled_message
    elsif current_board.tile_digest_email_sent_at.present?
      tiles_digest_last_sent_at_message
    end
  end

  def tiles_digest_scheduled_message
    "Tiles scheduled to send on #{current_board.tiles_digest_automator.next_deliver_time.strftime("%A, %B %d at %l:%M%p %Z")}"
  end

  def tiles_digest_last_sent_at_message
    "Last Tiles sent on #{current_board.tile_digest_email_sent_at.strftime("%A, %B %d at %l:%M%p %Z")}"
  end

  def tiles_digest_scheduled_time_class
    if current_board.tiles_digest_automator.present?
      "scheduled"
    end
  end
end
