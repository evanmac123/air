module SteakHelperMethods
  def mo_sms(sending_number, sms_body, server_number = TWILIO_PHONE_NUMBER)
    response = post sms_path, 'From' => sending_number, 'To' => server_number, 'Body' => sms_body, 'AccountSid' => Twilio::ACCOUNT_SID

    # When Twilio posts a message to us, if the response is plaintext, it sends
    # a reply with that text back to the original sender. We want to capture
    # those messages too, so we pretend like we posted them explicitly.

    if response.content_type.include? 'text/plain'
      FakeTwilio::SMS.post('To' => sending_number, 'Body' => response.body)
    end
  end
  
  def expect_mt_sms(receiving_number, expected_text)
    FakeTwilio::SMS.should have_sent_text(receiving_number, expected_text.gsub(/\\n/, "\n"))
  end
end
