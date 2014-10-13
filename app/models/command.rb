module Command
  def self.parse(user_or_phone, text, options={})
    allow_claim_account = options.delete(:allow_claim_account)

    # HRFF: We could cut down DB load significantly by looking up the user here
    # once and passing it around, rather than passing in user_or_phone

    SpecialCommand.parse(user_or_phone, text, options) ||
    User.send_invitation_if_claimed_sms_user_texts_us_an_email_address(user_or_phone, text, options) ||
    (allow_claim_account && User.claim_account(user_or_phone, options[:receiving_number], text, options).try(:first)) ||
    error_message(text)
  end

  def self.error_message(text)
    normalized_text = text.downcase.gsub(/\.$/, '').gsub(/\s+$/, '').gsub(/\s+/, ' ')

    "Sorry, I don't understand what \"#{normalized_text}\" means."
  end
end
