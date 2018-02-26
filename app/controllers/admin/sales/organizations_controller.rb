# frozen_string_literal: true

class Admin::Sales::OrganizationsController < AdminBaseController
  def new
    @sales_organization_creator = SalesOrganizationCreator.new(current_user)
    @default_board_id = default_sales_board
    @demos_to_select_from = demos_to_select_from
  end

  def create
    @sales_organization_creator = SalesOrganizationCreator.new(current_user, params[:copy_board], organization_params).create!
    if @sales_organization_creator.valid?
      user = @sales_organization_creator.user
      flash[:success] = flash_create_success(user)
      redirect_to explore_path
    else
      @default_board_id = default_sales_board
      @demos_to_select_from = demos_to_select_from
      render :new
    end
  end

  private

    def organization_params
      params.require(:organization).permit(:name, :is_hrm, demos_attributes: [:name], users_attributes: [:name, :email, :password, :is_client_admin], boards_attributes: [:name])
    end

    def flash_create_success(user)
      t("controllers.admin.sales.organizations.flash_create", name: user.name, invitation_url: invitation_url(user.invitation_code, demo_id: current_user.demo_id, new_lead: true))
    end

    def default_sales_board
      demos_to_select_from.where(name: "HR Bulletin Board").first.try(:id)
    end

    def demos_to_select_from
      Demo.select([:id, :name, :organization_id]).includes(:organization).order("organizations.name")
    end
end
