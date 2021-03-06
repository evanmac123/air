# frozen_string_literal: true

class Admin::OrganizationsController < AdminBaseController
  before_action :find_organization, only: [:edit, :show, :update, :destroy]

  def index
    @organizations = Organization.name_order
  end

  def new
    @organization = Organization.new
  end

  def create
    @organization = Organization.new(organization_params)
    if @organization.save
      flash[:success] = t("controllers.admin.organizations.flash_create", name: @organization.name)
      redirect_to admin_organization_path(@organization)
    else
      render :new
    end
  end

  def show
    unless @organization
      flash[:failure] = "Organization not found."
      redirect_to admin_path
    end
  end

  def edit
  end

  def update
    @organization.assign_attributes(organization_params)

    if @organization.save
      flash[:success] = "#{@organization.name} has been updated."
      redirect_to admin_organization_path(@organization)
    else
      render :show
    end
  end

  def destroy
    org_name = @organization.name
    if @organization == current_user.demo.organization
      flash[:failure] = "Switch out of #{org_name}'s demos in order to delete the organization."
    else
      @organization.delay.destroy
      flash[:success] = t("controllers.admin.organizations.flash_destroy", name: org_name)
    end

    redirect_to admin_path
  end

  private

    def find_organization
      @organization = Organization.find_by(slug: params[:id])
    end

    def organization_params
      params.require(:organization).permit(:name, :logo, :num_employees, :email, :internal, :free_trial_started_at, :company_size_cd)
    end
end
