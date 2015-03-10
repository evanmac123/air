module EmailPreviewsHelper
  def invitation_preview_url_with_referrer(user, referrer, root_url)
    referrer_hash = User.referrer_hash(referrer)
    path = invitation_preview_path({:code => user.invitation_code}.merge(@referrer_hash))
    root_url + path
  end
end
