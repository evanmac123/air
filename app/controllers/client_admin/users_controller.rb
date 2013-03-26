class ClientAdmin::UsersController < ClientAdminBaseController
  include ClientAdmin::UsersHelper

  must_be_authorized_to :client_admin
  before_filter :load_characteristics, only: [:create, :edit]
  before_filter :load_locations, only: [:create, :edit]
  before_filter :find_user, only: [:edit, :update, :destroy]
  before_filter :normalize_characteristic_ids_to_integers, only: [:create, :update]

  # Attributes that admins are allowed to set
  SETTABLE_USER_ATTRIBUTES = [:name, :email, :employee_id, :zip_code, :characteristics, :location_id, :"date_of_birth(1i)", :"date_of_birth(2i)", :"date_of_birth(3i)", :gender, :phone_number]

  # number of users displayable on one page when browsing
  PAGE_SIZE = 50

  def index
    respond_to do |format|
      format.html do
        if browse_request?
          render_browse_page
        else
          render_main_index_page
        end
      end

      format.js do
        render :inline => search_results_as_json
      end
    end
  end

  def create
    user_params = params[:user].filter_by_key(*SETTABLE_USER_ATTRIBUTES)
    @user = current_user.demo.users.new(user_params)

    if @user.save
      @user.generate_simple_claim_code!
      flash[:success] = "OK, we've added #{@user.name}."
      redirect_to client_admin_users_path
    else
      flash.now[:failure] = "Sorry, we weren't able to add that user. " + user_errors
      render :template => 'client_admin/users/index'
    end
  end

  def show
  end

  def edit
  end

  def update
    @user.attributes = params[:user].filter_by_key(*SETTABLE_USER_ATTRIBUTES)
    if @user.phone_number.present?
      @user.phone_number = PhoneNumber.normalize(@user.phone_number)
    end

    if @user.save
      flash[:success] = "OK, we've updated this user's information"
      redirect_to :back
    else
      load_characteristics
      load_locations
      flash.now[:failure] = "Sorry, we weren't able to change that user's information. " + user_errors
      render :template => "client_admin/users/edit"
    end
  end

  def destroy
    @user.destroy
    redirect_to client_admin_users_path
  end

  protected

  def browse_request?
    params[:begins_with].present? || params[:show_everyone].present?
  end

  def render_browse_page
    @offset = params[:offset].present? ? params[:offset].to_i : 0

    @users = current_user.demo.users.alphabetical.limit(PAGE_SIZE).offset(@offset)
    
    if params[:begins_with].present?
      @users = @users.name_starts_with(params[:begins_with])
      @result_description = '"' + params[:begins_with] + '"'
    else
      @result_description = "everyone"
    end

    @show_previous_link = @offset > 0
    @show_next_link = @offset + PAGE_SIZE < current_user.demo.users.count

    @next_page_url = client_admin_users_path(params.merge(offset: @offset + PAGE_SIZE))
    @previous_page_url = client_admin_users_path(params.merge(offset: @offset - PAGE_SIZE))
    render "browse"
  end

  def render_main_index_page
    @user = User.new(demo_id: current_user.demo_id)
    load_characteristics
    load_locations
  end

  def search_results_as_json
    normalized_term = params[:term].downcase.strip.gsub(/\s+/, ' ')
    users = current_user.demo.users.name_like(normalized_term).alphabetical_by_name.limit(10)
    users.map{|user| search_result(user)}.to_json
  end

  def search_result(user)
    {
      label: ERB::Util.h(user.name), 
      value: edit_client_admin_user_url(user)
    } 
  end

  def link_to_edit_user(user)
    url = edit_client_admin_user_path(user)
    %{<a href="#{url}">#{ERB::Util.h user.name}</a>}
  end

  def load_characteristics
    super(current_user.demo)
    @visible_characteristics = @generic_characteristics + @demo_specific_characteristics
  end

  def load_locations
    @locations = current_user.demo.locations.alphabetical
  end

  def find_user
    @user = current_user.demo.users.find_by_slug(params[:id])
  end

  def normalize_characteristic_ids_to_integers
    if params[:user].try(:[], :characteristics)
      params[:user][:characteristics] = Hash[params[:user][:characteristics].map{|key, value| [key.to_i, value]}]
    end
  end

  def user_errors
    @user.errors.smarter_full_messages.join(', ') + '.'  
  end
end
