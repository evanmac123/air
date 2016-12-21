# TODO: deprecate
module LoginByExploreToken
  def explore_token_allowed
    true
  end

  def current_user
    super || current_user_by_explore_token
  end

  def current_user_by_explore_token
    @current_user_by_explore_token
  end
end
