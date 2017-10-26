json.acts @acts do |act|
  json.userId act.user_id
  json.text act.text
  json.createdAt act.created_at
  json.points act.inherent_points

  json.helpers do
    json.userName user_first_name(user: act.user)
    json.createdAtForFeed time_ago_in_words(act.created_at)
    json.avatarPath user_avatar_path(user: act.user)
    json.userProfilePath user_profile_path(user: act.user)
    json.isGuest user_is_guest?(user: act.user)
    json.viewingSelf current_user_is_user?(user: act.user)
  end
end

json.meta do
  json.currentPage @acts.current_page
  json.nextPage @acts.next_page
  json.lastPage @acts.last_page?
end
