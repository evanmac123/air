require 'csv'

class Admin::UsersController < AdminBaseController
  before_filter :find_demo_by_demo_id
  before_filter :find_user, :only => [:edit, :update, :destroy]

  def index
    respond_to do |format|
      format.html do 
        starts_with = params[:starts_with]
        if starts_with == "non-alpha"
          @users = @demo.users.name_starts_with_non_alpha
        elsif starts_with
          @users = @demo.users.name_starts_with(params[:starts_with])
        else
          @users = @demo.users
        end

        @users = @users.order(&:name)
      end

      format.js do
        @users = @demo.users.where(:id => current_user.segmentation_results.found_user_ids).sort_by(&:name)
      end

      format.csv do
        @users = @demo.users.where(:id => current_user.segmentation_results.found_user_ids)
        render :index, :content_type => "text/csv", :layout => false
      end
    end
  end

  def create
    redirect_to :back

    @user = @demo.users.build(params[:user])

    unless @user.save
      flash[:failure] = "Cannot create that user: #{@user.errors.full_messages}"
      return
    end
    if params[:set_claim_code]
      @user.generate_simple_claim_code!
    end
  end

  def edit
    @demos = Demo.alphabetical
    @satisfiable_tiles = Tile.satisfiable_to_user(@user)
    @agnostic_characteristics = Characteristic.agnostic
    @demo_specific_characteristics = Characteristic.in_demo(@user.demo)
  end

  def update
    new_demo_id = params[:user].delete(:demo_id)

    @user.attributes = params[:user]

    @user.claim_code = nil if params[:user].has_key?(:claim_code) && params[:user][:claim_code].blank?
    @user.new_phone_number = @user.new_phone_validation = "" if ! params[:user][:phone_number].blank?

    if @user.save
      @user.move_to_new_demo(new_demo_id) if new_demo_id
      flash[:success] = "User updated."
      redirect_to admin_demo_path(@demo)
    else
      edit
      flash[:failure] = "Couldn't update user: #{@user.errors.full_messages.join(', ')}"
      render :edit
    end
  end

  def destroy
    @user.destroy
    flash[:success] = "All records on #{@user.name} destroyed"
    redirect_to admin_demo_path(@user.demo)
  end

  protected

  def find_user
    @user = @demo.users.find_by_slug(params[:id])
  end
end
