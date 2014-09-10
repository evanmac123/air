class Admin::DemosController < AdminBaseController
  before_filter :find_demo_by_id, :only => [:show, :edit, :update]
  before_filter :choose_tutorial_type, :only => [:create, :update]

  def new
    @demo = Demo.new
  end

  def create
    Demo.transaction do
      @demo = Demo.new(params[:demo])
      @demo.save!
      schedule_creation_ping
    end

    flash[:success] = "Demo created."
    redirect_to admin_demo_path(@demo)
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
  end

  def update
    @demo.attributes = params[:demo]

    if @demo.save
      flash[:success] = "Demo updated"
      redirect_to admin_demo_path(@demo)
    else
      flash.now[:failure] = "Couldn't update demo: #{@demo.errors.full_messages.join(', ')}"
      render :edit
    end
  end

  protected

  def massage_new_demo_parameters
    if params[:demo][:custom_welcome_message].blank?
      params[:demo].delete(:custom_welcome_message)
    end

    params[:demo].delete(:levels)
  end

  def choose_tutorial_type
    params[:demo][:tutorial_type] = if params.delete(:use_multiple_choice_tiles)
                                      'multiple_choice'
                                    else
                                      'keyword'
                                    end
  end

  def schedule_creation_ping
    ping 'Boards - New', {source: 'Site Admin'}, current_user
  end
end
