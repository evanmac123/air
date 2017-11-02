module CancelAccountToken
  def generate_cancel_account_token(user)
    Digest::SHA1.hexdigest("--#{Time.current.to_f}--#{user.email}--#{user.name}--#{user.id}--cancel_account")
  end
end
