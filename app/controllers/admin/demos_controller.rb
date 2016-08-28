class Admin::DemosController < AdminBaseController
  before_filter :find_demo_by_id, :only => [:show, :edit, :update]
  before_filter :params_correction, :only => [:create, :update]

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
    @claimed_user_count = @demo.users.claimed.count
    @user_with_game_referrer_count = @demo.users.with_game_referrer.count
    @locations = @demo.locations.alphabetical

    if params[:intercom_user_id]
      @intercom_user = User.find(params[:intercom_user_id]) # hack to send client admins to Intercom
    end
  end

  def edit
    @palette = @demo.custom_color_palette || @demo.build_custom_color_palette
  end

  def update
    if @demo.update_attributes(permitted_params.demo)
      flash[:success] = "Demo updated"
      if request.xhr?
        head :ok
      else
        redirect_to admin_demo_path(@demo)
      end
    else
      flash.now[:failure] = "Couldn't update demo: #{@demo.errors.full_messages.join(', ')}"
      render :edit
    end
  end

  protected

  #FIXME this should be handled in a before_[|save|valiation|] handler  
  def params_correction
    params[:demo][:is_public] = true if params[:demo][:is_parent]
  end


end
