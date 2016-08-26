class Admin::Sales::LeadContactsController < AdminBaseController
  def index
    @lead_contacts = LeadContact.scoped
  end

  def edit
    @lead_contact = LeadContact.find(params[:id])
    @organizations = Organization.select(:name)
  end

  def update
    lead_contact = LeadContactUpdater.new(lead_contact_params, params[:commit])

    if lead_contact.update
      lead_contact.dispatch
      redirect_to action: "index"
    else
      render "edit"
    end
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
