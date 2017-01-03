class Users::ActsController < UserBaseController
  def index
    if request.xhr?
      user = User.find_by_slug(params[:user_id])
      acts = user.acts.for_profile(current_user, params[:offset])
      render partial: 'shared/more_acts', locals: { acts: acts }
    end
  end
end
