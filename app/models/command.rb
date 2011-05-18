module Command
  def self.parse(user_or_phone, text, options={})
    allow_claim_account = options.delete(:allow_claim_account)

    SpecialCommand.parse(user_or_phone, text, options) ||
    (allow_claim_account && User.claim_account(user_or_phone, text, options)) ||
    Act.parse(user_or_phone, text, options)
  end
end
