module SteakHelperMethods
  def mo_sms(sending_number, sms_body, server_number = TWILIO_PHONE_NUMBER)
    response = post sms_path, 'From' => sending_number, 'To' => server_number, 'Body' => sms_body, 'AccountSid' => Twilio::ACCOUNT_SID
    # When Twilio posts a message to us, if the response is plaintext, it sends
    # a reply with that text back to the original sender. We want to capture
    # those messages too, so we pretend like we posted them explicitly.
    
    # For some reason the data we want comes in, at times on 'response', and at times, on '@response'
    response = @response if response.is_a? Fixnum
    if response.content_type.to_str.include? 'text/plain'
      FakeTwilio::SMS.post('To' => sending_number, 'Body' => response.body)
    end
  end
  
  def expect_mt_sms(receiving_number, expected_text)
    FakeTwilio::SMS.should have_sent_text(receiving_number, expected_text.gsub(/\\n/, "\n"))
  end

  def expect_no_mt_sms(receiving_number, expected_text=nil)
    if expected_text
      FakeTwilio::SMS.should_not have_sent_text(receiving_number, expected_text.gsub(/\\n/, "\n"))
    else
      FakeTwilio::SMS.should_not have_sent_text_to(receiving_number)
    end
  end

  def mt_sms_including?(receiving_number, expected_text)
    FakeTwilio::SMS.messages_to(receiving_number).any? {|message| message['Body'].include?(expected_text)}  
  end

  def expect_mt_sms_including(receiving_number, expected_text)
    mt_sms_including?(receiving_number, expected_text).should be_true
  end

  def expect_no_mt_sms_including(receiving_number, expected_text)
    mt_sms_including?(receiving_number, expected_text).should be_false
  end

  def dump_sent_texts
    puts
    puts "SENT TEXTS:"
    puts "-------------------------"
    FakeTwilio.sent_messages.each {|message| puts message.inspect}
    puts "-------------------------"
  end

end
