# frozen_string_literal: true

class Admin::OrganizationRegistrationsController < AdminBaseController
  def new
    @registration = OrganizationRegistration.new
  end

  def create
    @registration = OrganizationRegistration.new(registration_params)

    if @registration.save
      OrganizationRegistrationCompleter.call(@registration, current_user)
      flash[:success] = flash_create_success(@registration.user)
      redirect_to explore_path
    else
      render :new
    end
  end

  private

    def registration_params
      params.require(:organization_registration).permit(
        :organization_name,
        :user_name,
        :user_email,
        :board_name,
        :board_template_id
      )
    end

    def flash_create_success(user)
      t("controllers.admin.sales.organizations.flash_create", name: user.name, invitation_url: invitation_url(user.invitation_code, demo_id: current_user.demo_id, new_lead: true))
    end
end
