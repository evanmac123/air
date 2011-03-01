class UsersController < Clearance::UsersController
  layout :determine_layout

  def new
    redirect_to page_path(:id => 'invitation')
  end

  def show
    @user = User.find_by_slug(params[:id])
    @acts = @user.acts.recent(10)
  end
end
