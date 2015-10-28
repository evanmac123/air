class Admin::SupportsController < AdminBaseController
  layout "external"

  def show
    render 'supports/show'
  end
end
