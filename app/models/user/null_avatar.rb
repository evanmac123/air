class User::NullAvatar
  def url
    ActionController::Base.helpers.asset_path(User::MISSING_AVATAR_PATH)
  end
end
