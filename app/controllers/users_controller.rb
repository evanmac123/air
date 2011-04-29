class UsersController < Clearance::UsersController
  layout :determine_layout

  def new
    redirect_to page_path(:id => 'invitation')
  end

  def show
    @user = User.find_by_slug(params[:id])
    @acts = @user.acts.recent(10)
    @viewing_self = signed_in? && current_user == @user
    @viewing_other = signed_in? && current_user != @user
  end
end
