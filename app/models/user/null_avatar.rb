class User::NullAvatar
  def url
    ActionController::Base.helpers.image_path(User::MISSING_AVATAR_PATH)
  end
end
