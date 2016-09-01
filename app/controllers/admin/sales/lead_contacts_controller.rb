class Admin::Sales::LeadContactsController < AdminBaseController
  def index
    @lead_contacts = LeadContact.scoped
  end

  def edit
    @lead_contact = LeadContact.includes(:organization).find(params[:id])
    choose_state
  end

  def update
    lead_contact_updater = LeadContactUpdater.new(
      lead_contact_params,
      board_params[:board],
      params[:commit]
    )

    if lead_contact_updater.update
      lead_contact_updater.dispatch
      redirect_to admin_sales_lead_contacts_path(status: lead_contact_updater.status)
    else
      flash[:failure] = "This email you entered is used by an existing lead or user."
      redirect_to edit_admin_sales_lead_contact_path(lead_contact_updater.lead_contact)
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

    def board_params
      params.permit(
        board: [
          :template_id,
          :name,
          :logo,
          :custom_reply_email_name
        ]
      )
    end

    def choose_state
      if @lead_contact.status == "pending"
        @organizations = Organization.select(:name)
      elsif @lead_contact.status == "approved"
        @stock_boards = Demo.stock_boards.select([:id, :name, :public_slug])
        @user = User.new(name: @lead_contact.name, email: @lead_contact.email, organization_id: @lead_contact.organization.id)
        @board = @user.demos.new(name: @lead_contact.organization_name)
        @board_names = Demo.pluck(:name)
      end
    end
end
