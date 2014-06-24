class ClientAdmin::UsersController < ClientAdminBaseController
  include ClientAdmin::UsersHelper

  before_filter :load_locations, only: [:create, :edit]
  before_filter :create_uploader
  before_filter :find_user, only: [:edit, :update, :destroy]
  before_filter :normalize_characteristic_ids_to_integers, only: [:create, :update]
  before_filter :count_total_users

  # Attributes that admins are allowed to set
  SETTABLE_USER_ATTRIBUTES = [:name, :email, :employee_id, :zip_code, :characteristics, :location_id, :"date_of_birth(1i)", :"date_of_birth(2i)", :"date_of_birth(3i)", :gender, :phone_number]

  # number of users displayable on one page when browsing
  PAGE_SIZE = 50

  def index
    respond_to do |format|
      @demo = current_user.demo
      @tiles_to_be_sent = @demo.digest_tiles(@demo.tile_digest_email_sent_at).count
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
    @demo = current_user.demo
    user_params = params[:user].slice(*SETTABLE_USER_ATTRIBUTES)

    email = user_params['email'].try(:downcase)
    existing_user = if email.present?
      User.find_by_email(email)
    end
    if existing_user.present? && existing_user.in_board?(@demo)
      flash[:notice] = "It looks like #{existing_user.email} is already in your board."
      redirect_to :back
      return
    end

    @user = existing_user || current_user.demo.users.new(user_params)
    @user.role = params[:user].delete(:role)
      
    if save_if_date_good(@user) # sigh
      make_this_board_current = existing_user.nil?
      @user.add_board(@demo.id, make_this_board_current)

      @user.generate_unique_claim_code! unless @user.claim_code.present?

      put_add_success_in_flash
      send_creation_ping(existing_user)
      redirect_to client_admin_users_path
    else
      # This is a stupid hack. The more time goes on, the more I think Rails
      # validations are just not where they should be.

      add_date_of_birth_error_if_needed(@user)
      flash.now[:failure] = "Sorry, we weren't able to add that user. " + user_errors
      render :template => 'client_admin/users/index'
    end
  end

  def show
  end

  def edit
    @demo = current_user.demo
  end

  def update
    @demo = current_user.demo

    user_in_current_demo = (@user.demo == @demo)
    @new_role = params[:user].delete(:role)
    unless user_in_current_demo
      @new_location_id = params[:user].delete(:location_id)
    end

    @user.attributes = params[:user].slice(*SETTABLE_USER_ATTRIBUTES)
    if @user.phone_number.present?
      @user.phone_number = PhoneNumber.normalize(@user.phone_number)
    end
    @user.role = @new_role
    
    if save_if_date_good(@user)
      unless user_in_current_demo
        @user.board_memberships.find_by_demo_id(@demo.id).
          update_attributes(location_id: @new_location_id, role: @new_role)
      end

      flash[:success] = "OK, we've updated this user's information"
      redirect_to edit_client_admin_user_path(@user)
    else
      add_date_of_birth_error_if_needed(@user)
      load_locations
      flash.now[:failure] = "Sorry, we weren't able to change that user's information. " + user_errors
      render :template => "client_admin/users/edit"
    end
  end

  def destroy
    @user.destroy
    redirect_to client_admin_users_path
  end
    
  def validate_email
    if params[:email].downcase == current_user.email
      render text: "This is you!"
    else
      render nothing: true
    end
  end

  protected

  def browse_request?
    params[:show_everyone].present?
  end

  def render_browse_page
    @offset = params[:offset].present? ? params[:offset].to_i : 0

    @users = current_user.demo.users.where(is_site_admin: false).alphabetical.limit(PAGE_SIZE).offset(@offset)
    
    @result_description = "everyone"

    @show_previous_link = @offset > 0
    @show_next_link = @offset + PAGE_SIZE < current_user.demo.users.count

    @next_page_url = client_admin_users_path(params.merge(offset: @offset + PAGE_SIZE))
    @previous_page_url = client_admin_users_path(params.merge(offset: @offset - PAGE_SIZE))
    render "browse"
  end

  def render_main_index_page
    @user = User.new(demo_id: current_user.demo_id)
    create_uploader
    load_locations
  end

  def search_results_as_json
    normalized_term = params[:term].downcase.strip.gsub(/\s+/, ' ')
    users = current_user.demo.users.name_like(normalized_term).alphabetical_by_name.limit(10)

    if users.empty?
      add_user_json(normalized_term)
    else
      users.map{|user| search_result(user)}.to_json
    end
  end

  def search_result(user)
    {
      label: ERB::Util.h(user.name), 
      value: {
        found: true,
        url:   edit_client_admin_user_url(user)
      }
    } 
  end

  def add_user_json(normalized_name)
    name = normalized_name.split.map(&:capitalize).join(' ')
    label = ERB::Util.h(%{No match for "#{name}". Click to add this user.})

    [{
        label: label,
        value: {
          found: false,
          name: name
        }
      }].to_json
  end

  def link_to_edit_user(user)
    url = edit_client_admin_user_path(user)
    %{<a href="#{url}">#{ERB::Util.h user.name}</a>}
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

  def put_add_success_in_flash
    if @user.invitable?
      flash[:success] = %{Success! <a href="#{client_admin_user_invitation_path(@user)}" class="invite-user">Next, send invite to #{@user.name}</a> <span id="inviting-message" style="display: none">Inviting...</span></span>}
      flash[:success_allow_raw] = true
    else
      flash[:success] = "OK, we've added #{@user.name}. They can join the game with the claim code #{@user.claim_code.upcase}."
    end
  end

  def all_date_of_birth_parts_valid?(user)
    date_part_keys = %w{date_of_birth(1i) date_of_birth(2i) date_of_birth(3i)}
    number_present = date_part_keys.count {|date_part_key| params[:user][date_part_key].present?}

    number_present == 0 || number_present == 3
  end

  def save_if_date_good(user)
    all_date_of_birth_parts_valid?(user) && user.save
  end

  def add_date_of_birth_error_if_needed(user)
    unless all_date_of_birth_parts_valid?(user)
      user.errors.add(:base, "Please enter a full date of birth")
    end
  end  

  def send_creation_ping(existing_user)
    event = existing_user.present? ? "User - Existing Invited" : "User - New"
    ping(event, source: 'creator')
  end

  def create_uploader
    @uploader = BulkUserUploader.new
    @uploader.success_action_redirect = client_admin_bulk_upload_url
  end

  def count_total_users
    @total_user_count = current_user.demo.users.claimed.where(is_site_admin: false).count
  end
end
