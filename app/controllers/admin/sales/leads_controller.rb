class Admin::Sales::LeadsController < AdminBaseController
  include SalesAcquisitionConcern

  def index
    @leads = current_leads
    @my_leads = my_leads
  end
end
