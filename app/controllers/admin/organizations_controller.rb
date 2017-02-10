require 'file_upload_wrapper'
require 'custom_responder'
class Admin::OrganizationsController < AdminBaseController
  include CustomResponder
  include SalesAcquisitionConcern

  before_filter :find_organization, only: [:edit, :show, :update, :destroy]

  def index
    @organizations = Organization.name_order
  end

  def new
    @organization = Organization.new
  end

  def create
    @organization = Organization.new(organization_params)
    if @organization.save
      flash[:success] = t('controllers.admin.organizations.flash_create', name: @organization.name)
      redirect_to admin_organization_path(@organization)
    else
      render :new
    end
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

  def edit
  end

  def update
    @organization.assign_attributes(organization_params)

    if @organization.save
      flash[:success] = "#{@organization.name} has been updated."
      redirect_to admin_organization_path(@organization)
    else
      render :edit
    end
  end

  def destroy
    @organization.destroy
    flash[:success] = t('controllers.admin.organizations.flash_destroy', name: @organization.name)
    redirect_to admin_path
  end

  private

    def find_organization
      @organization = Organization.find_by_slug(params[:id])
    end

    def organization_params
      params.require(:organization).permit(:name, :logo, :num_employees, :featured)
    end
end
