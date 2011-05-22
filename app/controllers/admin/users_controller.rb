class Admin::UsersController < AdminBaseController
  before_filter :find_user, :only => [:edit, :update]

  def create
    @demo = Demo.find(params[:demo_id])
    @user = @demo.users.build(params[:user])
    @user.save!

    if params[:set_claim_code]
      @user.generate_simple_claim_code!
    end

    redirect_to :back
  end

  def edit
    @demos = Demo.alphabetical
  end

  def update
    new_demo_id = params[:user].delete(:demo_id)

    @user.attributes = params[:user]
    if params[:user].has_key?(:claim_code) && params[:user][:claim_code].blank?
      @user.claim_code = nil
    end

    if @user.save
      @user.move_to_new_demo(new_demo_id) if new_demo_id
      flash[:success] = "User updated."
    else
      flash[:failure] = "Couldn't update user: #{@user.errors.full_messages.join(', ')}"
    end

    redirect_to admin_demo_path(@demo)
  end

  protected

  def find_user
    @demo = Demo.find(params[:demo_id])
    @user = @demo.users.find_by_slug(params[:id])
  end
end
