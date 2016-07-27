class Admin::DependentBoards::UsersController < AdminBaseController
  before_filter :find_demo_by_demo_id

  def index
    @active = params[:active]
    respond_to do |format|
      format.csv do
        if @active == "true"
          @users = @demo.users
        elsif @active == "false"
          @users = @demo.potential_users
          render :index, :content_type => "text/csv", :layout => false
        end
      end
    end
  end
end
