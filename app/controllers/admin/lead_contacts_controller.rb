class Admin::LeadContactsController < AdminBaseController
  def index
    @lead_contacts = LeadContact.scoped
  end

  def edit
  end

  def update
  end

  def create
  end
end
