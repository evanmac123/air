module ClientAdmin::SharesHelper
  def digest_sent_modal_title(digest_type)
    if digest_type == "digest_delivered"
      "Congratulations!"
    else
      "Test Sent"
    end
  end

  def digest_sent_modal_text(digest_type)
    if digest_type == "digest_delivered"
      "Your Tiles have been successfully sent. New Tiles you post will appear in the email preview."
    else
      test_digest_modal_message(digest_type)
    end
  end

  def test_digest_modal_message(digest_type)
    case digest_type
    when "test_digest"
      test_email_sent_message_template("Tiles Email")
    when "test_digest_with_sms"
      test_email_sent_message_template("Tiles Email", sms_sent_template_message)
    when "test_digest_and_follow_up"
      test_email_sent_message_template("Tiles Email and Follow-up Email")
    when "test_digest_and_follow_up_with_sms"
      test_email_sent_message_template("Tiles Email and Follow-up Email", sms_sent_template_message)
    end
  end

  def test_email_sent_message_template(emails_sent, sms_sent_message=nil)
    "A test #{emails_sent} has been sent to #{current_user.email}. #{sms_sent_message}."
  end

  def sms_sent_template_message
    current_user_receives_sms = current_user.phone_number.present?

    if current_user_receives_sms
      "Any test text messages have been sent to #{current_user.phone_number}"
    else
      "No test text messages could be sent because your phone number is not set in Airbo. You may add your phone number #{link_to 'here', edit_account_settings_path}"
    end
  end

  def shares_follow_ups_header(follow_ups)
    if follow_ups.present?
      "Scheduled Follow-Ups"
    else
      "No Follow-Ups Scheduled"
    end
  end

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
