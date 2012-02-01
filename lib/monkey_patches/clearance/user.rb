module Clearance::User
  module ClassMethods

    def authenticate_with_username_as_valid_identifier(identifier, password)
      user = authenticate_without_username_as_valid_identifier(identifier, password)
      return user if user

      return nil unless (user = User.find_by_sms_slug(identifier))
      return user if user.authenticated?(password)
    end

    alias_method_chain :authenticate, :username_as_valid_identifier
  end
end
