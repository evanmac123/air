module Command
  def self.parse(user_or_phone, text, options={})
    allow_claim_account = options.delete(:allow_claim_account)

    SpecialCommand.parse(user_or_phone, text, options) ||
    User.send_invitation_if_claimed_sms_user_texts_us_an_email_address(user_or_phone, text, options) ||
    (allow_claim_account && User.claim_account(user_or_phone, options[:receiving_number], text, options).try(:first)) ||
    Act.parse(user_or_phone, text, options)
  end
end
