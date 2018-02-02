# frozen_string_literal: true

class Admin::Sales::LeadContactsController < AdminBaseController
  def index
    @lead_contacts = LeadContact.all
  end

  def destroy
    LeadContact.find(params[:id]).destroy

    redirect_to admin_sales_lead_contacts_path
  end

  def create
    LeadContact.create(lead_contact_params)

    redirect_to root_path(signup_request: true)
  end

  private

    def lead_contact_params
      params.require(:lead_contact).permit(
        :name,
        :email,
        :phone,
        :organization_name,
        :organization_size,
        :new_organization,
        :matched_organization,
        :source,
        :id
      )
    end
end
