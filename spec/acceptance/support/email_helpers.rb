def email_originated_message_received(from_email, email_subject, email_body)
  post email_path, 'from' => from_email, 'subject' => email_subject, 'to' => "email_commands@hengage.net", 'plain' => email_body
end


