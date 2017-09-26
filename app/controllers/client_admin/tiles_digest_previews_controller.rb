class ClientAdmin::TilesDigestPreviewsController < ClientAdminBaseController
  layout false
  prepend_before_filter :allow_same_origin_framing

  def sms
    @digest = params[:digest]
  end
end
