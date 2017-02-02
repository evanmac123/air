class Admin::Sales::LeadsController < AdminBaseController
  def index
    @leads = Organization.with_role(:sales)
    @my_leads = @leads.with_role(:sales, current_user)
  end
end
