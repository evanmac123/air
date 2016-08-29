class LeadContactUpdater
  attr_reader :lead_contact, :attributes, :board_params, :action

  def initialize(lead_contact_params, board_params, action)
    normalize_params(lead_contact_params)
    @lead_contact = LeadContact.find(lead_contact_params["id"])
    @attributes = base_attributes(lead_contact_params)
    @board_params = board_params
    @action = action.downcase
  end

  def dispatch
    begin
      self.send(action)
    rescue
      true
    end
  end

  def update
    lead_contact.update_attributes(attributes)
  end

  def approve
    organization = find_or_create_organization
    lead_contact.update_attributes(status: "approved", organization: organization)
  end

  def deny
    lead_contact.update_attributes(status: "denied")
    LeadContactNotifier.delay_mail(:denial, lead_contact)
  end

  def process
    LeadContactProcessor.dispatch(lead_contact, board_params)
    lead_contact.update_attributes(status: "processed")
  end

  def status
    lead_contact.status
  end

  private

    def normalize_params(params)
      params.update(params) { |_k, v| v.empty? ? nil : v }
    end

    def base_attributes(params)
      {
        name: params["name"],
        email: params["email"] || "invalid",
        phone: params["phone"] || "invalid",
        organization_name: params["matched_organization"] || params["organization_name"],
        organization_size: params["organization_size"] || lead_contact.organization_size
      }
    end

    def find_or_create_organization
      Organization.where(
        name: lead_contact.organization_name
      ).first_or_create(
        size_estimate: lead_contact.organization_size,
        sales_channel: "inbound"
      )
    end
end
