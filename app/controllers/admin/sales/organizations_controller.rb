class Admin::Sales::OrganizationsController < AdminBaseController
  include SalesAcquisitionConcern

  def new
    @sales_organization_creator = SalesOrganizationCreator.new(current_user)
  end

  def create
    @sales_organization_creator = SalesOrganizationCreator.new(current_user, params[:copy_board], organization_params).create!
    if @sales_organization_creator.valid?
      user = @sales_organization_creator.user
      ping_new_lead_for_sales(user)
      flash[:success] = flash_create_success(user)
      redirect_to explore_path
    else
      render :new
    end
  end

  private

    def organization_params
      params.require(:organization).permit(:name, :is_hrm, demos_attributes: [:name], users_attributes: [:name, :email, :password, :is_client_admin], boards_attributes: [:name])
    end

    def flash_create_success(user)
      t('controllers.admin.sales.organizations.flash_create', name: user.name, invitation_url: invitation_url(user.invitation_code, { demo_id: current_user.demo_id, new_lead: true }))
    end
end
