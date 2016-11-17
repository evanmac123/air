require 'file_upload_wrapper'
require 'custom_responder'
class Admin::OrganizationsController < AdminBaseController
  include CustomResponder

  before_filter :find_organization, only: [:edit, :show, :update, :destroy]

  def index
    @organizations = Organization.name_order
  end

  def show
  end
  def import
    importer = OrganizationImporter.new(FileUploadWrapper.new(params[:file]))
    org = nil
    importer.rows.each do |row|
      org = Organization.where(name: row["Company"]).first_or_initialize
      org.save
    end
    redirect_to admin_organizations_path
  end


  def new
    @organization = Organization.new
    @user = @organization.users.build
    @board = @organization.boards.build
  end

  def edit
    new_or_edit @organization
  end

  def create
    @organization = Organization.new(organization_params)
    if @organization.save
      user = @organization.users.first
      board = @organization.boards.first
      link_board_and_user(user, board)
      current_user.move_to_new_demo(board)
      flash[:success] = "Invitation URL for #{user.name}: #{ invitation_url(user.invitation_code)}"
      redirect_to explore_path
    else
      render :new
    end
  end

  def update
    @organization.assign_attributes organization_params
    update_or_create @organization, admin_organizations_path(@organization)
  end

  private

  def find_organization
    @organization = Organization.find(params[:id])
  end

  def organization_params
    params.require(:organization).permit(:churn_reason, :name, :is_hrm, :num_employees, :sales_channel, demos_attributes: [:name], users_attributes: [:name, :email, :password], boards_attributes: [:name])
  end

  def link_board_and_user(user, board)
    user.board_memberships.create(demo: board)
  end
end
