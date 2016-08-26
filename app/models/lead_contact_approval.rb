class LeadContactApproval
  attr_reader :lead_contact

  def self.dispatch(lead_contact, new_organization)
    approval = LeadContactApproval.new(lead_contact, new_organization)
    approval.process
  end

  def initialize(lead_contact, new_organization)
    @lead_contact = lead_contact
    @organization = find_or_create_organization(new_organization)
  end

  def process

  end

  private
    
end
