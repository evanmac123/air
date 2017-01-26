class Admin::Sales::LeadsController < AdminBaseController
  include SalesAquisitionConcern

  def index
    @leads = current_leads
    @my_leads = my_leads
  end
end
