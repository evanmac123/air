class ClientAdmin::UsersController < ClientAdminBaseController
  include ClientAdmin::UsersHelper

  # before_filter :load_locations, only: [:create, :edit]
  before_filter :create_uploader
  before_filter :find_user, only: [:edit, :update, :destroy]
  before_filter :normalize_characteristic_ids_to_integers, only: [:create, :update]
  before_filter :count_total_users, only: :index

  # Attributes that admins are allowed to set
  # SETTABLE_USER_ATTRIBUTES = [:name, :email, :employee_id, :zip_code, :characteristics, :location_id, :"date_of_birth(1i)", :"date_of_birth(2i)", :"date_of_birth(3i)", :gender, :phone_number]
  SETTABLE_USER_ATTRIBUTES = [:name, :email, :characteristics, :phone_number]
  # number of users displayable on one page when browsing
  PAGE_SIZE = 50

  def index
    ping_page("Manage - Users", current_user)
    respond_to do |format|
      @demo = current_user.demo
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
    user_params = params[:user].
                    slice(*SETTABLE_USER_ATTRIBUTES).
                    merge({email: params[:user][:email].try(:downcase).try(:strip)})

    email = user_params['email']
    existing_user = if email.present?
      User.find_by_email(email)
    end
    if existing_user.present? && existing_user.in_board?(@demo)
      flash[:notice] = "It looks like #{existing_user.email} is already in your board."
      redirect_to :back
      return
    end

    @user = existing_user || current_user.demo.users.new(user_params)
    is_new_user = existing_user.nil?
    role = params[:user].delete(:role)
    
    if @user.save
      make_this_board_current = existing_user.nil?
      @user.add_board(@demo.id, is_new_user)

      if is_new_user
        @user.role = role
        @user.save!
      end
      new_board_membership = @user.board_memberships.where(demo_id: @demo.id).first
      new_board_membership.role = role
      new_board_membership.save!

      @user.generate_unique_claim_code! unless @user.claim_code.present?

      put_add_success_in_flash
      send_creation_ping(existing_user)
      ping_if_made_client_admin(@user, @user.is_client_admin)
      redirect_to client_admin_users_path
    else
      flash.now[:failure] = "Sorry, we weren't able to add that user. " + user_errors
      render :template => 'client_admin/users/index'
    end
  end

  def edit
    @demo = current_user.demo
  end

  def update
    @demo = current_user.demo

    user_in_current_demo = (@user.demo == @demo)
    @new_role = params[:user].delete(:role)
    role_was_changed = (@new_role != @user.role)

    @user.attributes = params[:user].slice(*SETTABLE_USER_ATTRIBUTES)
    if @user.phone_number.present?
      @user.phone_number = PhoneNumber.normalize(@user.phone_number)
    end
    @user.role = @new_role
    
    if @user.save
      ping_if_made_client_admin(@user, role_was_changed)
      flash[:success] = "OK, we've updated this user's information"
      redirect_to edit_client_admin_user_path(@user)
    else
      flash.now[:failure] = "Sorry, we weren't able to change that user's information. " + user_errors
      render :template => "client_admin/users/edit"
    end
  end

  def destroy
    @user.destroy
    redirect_to client_admin_users_path
  end
    
  # def validate_email
  #   if params[:email].downcase == current_user.email
  #     render text: "This is you!"
  #   else
  #     render nothing: true
  #   end
  # end

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
    @user = User.new
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
        url:   edit_client_admin_user_url(user),
        id: user.id
      }
    } 
  end

  def add_user_json(normalized_name)
    name = normalized_name.split.map(&:capitalize).join(' ')
    label = "No match for #{name}. <span class='add_user'>Click to add this user.</span>".html_safe
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

  # def all_date_of_birth_parts_valid?(user)
  #   date_part_keys = %w{date_of_birth(1i) date_of_birth(2i) date_of_birth(3i)}
  #   number_present = date_part_keys.count {|date_part_key| params[:user][date_part_key].present?}

  #   number_present == 0 || number_present == 3
  # end

  # def save_if_date_good(user)
  #   all_date_of_birth_parts_valid?(user) && user.save
  # end

  # def add_date_of_birth_error_if_needed(user)
  #   unless all_date_of_birth_parts_valid?(user)
  #     user.errors.add(:base, "Please enter a full date of birth")
  #   end
  # end  

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

  def ping_if_made_client_admin(user, was_changed)
    if user.is_client_admin && was_changed
      ping('Creator - New', {source: 'Client Admin'}, current_user)
    end
  end
end
