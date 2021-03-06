# frozen_string_literal: true

class ClientAdmin::UsersController < ClientAdminBaseController
  include ClientAdmin::UsersHelper

  before_action :create_uploader
  before_action :find_user, only: [:edit, :update, :destroy]
  before_action :normalize_characteristic_ids_to_integers, only: [:create, :update]
  before_action :count_total_users, only: :index

  # Attributes that admins are allowed to set
  SETTABLE_USER_ATTRIBUTES = [:name, :email, :role, :phone_number, :population_segments_ids]
  # number of users displayable on one page when browsing
  PAGE_SIZE = 50

  def index
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
        render inline: search_results_as_json
      end
    end
  end

  def create
    @demo = current_user.demo
    params2 =  user_params.merge(email: params[:user][:email].try(:downcase).try(:strip))
    user_maker = MakeSimpleUser.new params2, @demo, current_user

    if user_maker.existing_user_in_board?
      flash[:notice] = "It looks like #{user_maker.existing_user.email} is already in your board."
      redirect_to :back
      return
    end

    user_saved = user_maker.create
    @user = user_maker.user
    if user_saved
      put_add_success_in_flash
      send_creation_ping(user_maker.existing_user)
      redirect_to client_admin_users_path
    else
      flash.now[:failure] = "Sorry, we weren't able to add that user. " + user_maker.user_errors
      render template: "client_admin/users/index"
    end
  end

  def edit
    @demo = current_user.demo
  end

  def update
    @demo = current_user.demo
    user_maker = MakeSimpleUser.new user_params, @demo, current_user, @user
    user_saved = user_maker.update
    @user = user_maker.user

    if user_saved
      flash[:success] = "OK, we've updated this user's information"
      redirect_to edit_client_admin_user_path(@user)
    else
      flash.now[:failure] = "Sorry, we weren't able to change that user's information. " + user_maker.user_errors
      render template: "client_admin/users/edit"
    end
  end

  def destroy
    @user.delay.destroy
    flash[:success] = "User #{@user.name} has been marked for deletion. The deletion may take  few minutes to complete"
    redirect_to client_admin_users_path
  end

  private

    def user_params
      @user_params ||= permitted_params.user
    end

    def browse_request?
      params[:show_everyone].present?
    end

    def render_browse_page
      @offset = params[:offset].present? ? params[:offset].to_i : 0

      users = current_user.demo.users.where(is_site_admin: false)

      @client_admin = users.client_admin.alphabetical
      @users = users.non_admin.alphabetical.limit(PAGE_SIZE).offset(@offset)
      @result_description = "everyone"

      @show_previous_link = @offset > 0
      @show_next_link = @offset + PAGE_SIZE < current_user.demo.users.count

      @next_page_url = client_admin_users_path(show_everyone: params[:show_everyone], offset: @offset + PAGE_SIZE)
      @previous_page_url = client_admin_users_path(show_everyone: params[:show_everyone], offset: @offset - PAGE_SIZE)
      render :browse
    end

    def render_main_index_page
      @user = User.new
      create_uploader
      load_locations
    end

    def load_locations
      @locations = current_user.demo.locations.alphabetical
    end

    def search_results_as_json
      normalized_term = params[:term].downcase.strip.gsub(/\s+/, " ")
      users = current_user.demo.users.name_like(normalized_term).alphabetical_by_name.limit(10)

      if users.empty?
        add_user_json(normalized_term)
      else
        users.map { |user| search_result(user) }.to_json
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
      name = normalized_name.split.map(&:capitalize).join(" ")
      label = "No match for #{name}."
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
      @user = current_user.demo.users.find_by(slug: params[:id]) ||
                current_user.demo.users.find(params[:id])
    end

    def normalize_characteristic_ids_to_integers
      if params[:user].try(:[], :characteristics)
        params[:user][:characteristics] = Hash[params[:user][:characteristics].map { |key, value| [key.to_i, value] }]
      end
    end

    def put_add_success_in_flash
      if @user.invitable?
        flash[:success] = %{Success! <a href="#{client_admin_user_invitation_path(@user)}" class="invite-user">Next, send invite to #{@user.name}</a> <span id="inviting-message" style="display: none">Inviting...</span></span>}
        flash[:success_allow_raw] = true
      else
        flash[:success] = "OK, we've added #{@user.name}. They can join the game with the claim code #{@user.claim_code.upcase}."
      end
    end

    def send_creation_ping(existing_user)
      event = existing_user.present? ? "User - Existing Invited" : "User - New"
      ping(event, source: "creator")
    end

    def create_uploader
      @uploader = BulkUserUploader.new
      @uploader.success_action_redirect = client_admin_bulk_upload_url
    end

    def count_total_users
      @total_user_count = current_board.board_memberships.non_site_admin.claimed.count
    end
end
