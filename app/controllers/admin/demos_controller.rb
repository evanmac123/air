# frozen_string_literal: true

class Admin::DemosController < AdminBaseController
  before_action :find_demo_by_id, only: [:show, :edit, :update]

  def index
    @demos = Demo.active.list_with_org_name_and_user_count
  end

  def new
    @demo = Demo.new
  end

  def create
    @demo = Demo.new(permitted_params.demo)
    if @demo.save
      flash[:success] = "Demo created."
      redirect_to admin_demo_path(@demo)
    else
      render :new
    end
  end

  def show
    @users = @demo.users.alphabetical
    @user_with_mobile_count = @demo.users.with_phone_number.count
    @claimed_user_count = @demo.board_memberships.non_site_admin.claimed.count
    @user_with_game_referrer_count = @demo.users.with_game_referrer.count
    @locations = @demo.locations.alphabetical
  end

  def edit
  end

  def update
    @demo.assign_attributes(permitted_params.demo)

    if @demo.save
      if request.xhr?
        head :ok
      else
        flash[:success] = "Demo updated"
        redirect_to admin_demo_path(@demo)
      end
    else
      flash.now[:failure] = "Couldn't update demo: #{@demo.errors.full_messages.join(', ')}"
      render :edit
    end
  end

  def destroy
    board = Demo.find(params[:id])
    board.set_for_delete
    flash[:success] = "#{board.name} successfully scheduled for deletion"
    redirect_to admin_demos_path
  end

  private

    def find_demo_by_id
      @demo = Demo.find(params[:id])
    end
end
