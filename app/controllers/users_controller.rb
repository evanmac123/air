class UsersController < Clearance::UsersController
  before_filter :mobile_if_ajax

  def new
    redirect_to page_path(:id => 'invitation')
  end

  def show
    @user = User.find_by_slug(params[:id])
    @acts = @user.acts.recent(10)
  end
end
