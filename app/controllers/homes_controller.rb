class HomesController < UserBaseController
  def show
    if request.cookies["user_onboarding"].present? && !current_user.user_onboarding.completed
      redirect_to user_onboarding_path(current_user.user_onboarding.id, return_onboarding: true)
    elsif current_user.is_client_admin? || current_user.is_site_admin?
      redirect_to explore_path, :format => :html
    else
      redirect_to activity_path
    end
  end
end
