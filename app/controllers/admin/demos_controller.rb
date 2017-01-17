class Admin::DemosController < AdminBaseController
  before_filter :find_demo_by_id, :only => [:show, :edit, :update]

  def index
    @demos = Demo.list
  end

  def new
    @demo = Demo.new
    @palette = @demo.build_custom_color_palette
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
    @claimed_user_count = @demo.claimed_user_count
    @user_with_game_referrer_count = @demo.users.with_game_referrer.count
    @locations = @demo.locations.alphabetical
  end

  def edit
    @palette = @demo.custom_color_palette || @demo.build_custom_color_palette
  end

  def update
    if @demo.update_attributes(permitted_params.demo)
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
    board = Demo.find(params[:id]).destroy
    flash[:success] = "#{board.name} deleted"
    redirect_to admin_demos_path
  end

  private

    def find_demo_by_id
      @demo = Demo.find(params[:id])
    end
end
