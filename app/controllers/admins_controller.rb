class AdminsController < AdminBaseController
  def show
    @current_user = current_user
    @organizations = Organization.includes(:demos).select([:name, :id, :is_hrm, :slug, :demos_count]).name_order
    render template: 'admin/show'
  end
end
