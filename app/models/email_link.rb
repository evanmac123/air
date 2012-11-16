module EmailLink
  SALT = "Why don't they call this PEPPER?"

  def self.generate_token(model_instance)
    Digest::SHA1.hexdigest model_instance.id.to_s + SALT
  end

  def self.validate_token(model_instance, token)
    token == generate_token(model_instance)
  end
end
