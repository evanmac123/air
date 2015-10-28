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
    @support.update_attributes(params[:support])
    redirect_to 'edit'
  end
end
