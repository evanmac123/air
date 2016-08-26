class LeadContactUpdater
  attr_reader :lead_contact, :attributes, :routing_attributes, :action

  def initialize(params, action)
    normalize_params(params)
    @lead_contact = LeadContact.find(params["id"])
    @attributes = base_attributes(params)
    @routing_attributes = routing_hash(params)
    @action = action
  end

  def dispatch
    self.send(action)
  end

  def update
    refresh_base_attributes
    lead_contact.update_attributes(attributes)
  end

  def approve
    binding.pry
  end

  def deny
    binding.pry
  end

  private
  
    def normalize_params(params)
      params.update(params) { |_k, v| v.empty? ? nil : v }
    end

    def base_attributes(params)
      {
        name: params["name"],
        email: params["email"],
        phone: params["phone"],
        organization_name: params["organization_name"],
        organization_size: params["organization_size"]
      }
    end

    def routing_hash(params)
      {
        new_organization: params["new_organization"],
        matched_organization: params["matched_organization"]
      }
    end

    def validate_organization_name
      routing_attributes[:matched_organization] || attributes[:organization_name]
    end

    def validate_organization_size
      attributes[:organization_size] || lead_contact.organization_size
    end

    def refresh_base_attributes
      attributes[:email] ||= "invalid"
      attributes[:phone] ||= "invalid"
      attributes[:organization_size] ||= lead_contact.organization_size
      attributes[:organization_name] = validate_organization_name
    end
end
