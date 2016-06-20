class Admin::SupportsController < AdminBaseController
  layout "support"

  def show
    @support = Support.instance
    @content_path = "supports/content"
    render 'supports/show'
  end

  def edit
    @content_path = "admin/supports/form"
    @support = Support.instance
    render 'supports/show'
  end

  def update
    @support = Support.instance
    @support.update_attributes(permit_params)
    redirect_to edit_admin_support_path
  end

  private
    def permit_params
      params.require(:support).permit!
    end
end
