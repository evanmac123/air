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
end
