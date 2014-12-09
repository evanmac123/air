class Admin::ExploreDigestsController < AdminBaseController
  def new
    @explore_digest_form = NullExploreDigestForm.new
  end

  def create
    @explore_digest_form = if params[:commit] == 'Send real digest'
                             ExploreDigestForm.new(params[:explore_digest_form])
                           else
                             ExploreDigestTestForm.new(params[:explore_digest_form], current_user)
                           end
    @explore_digest_form.send_digest!

    redirect_to :back
  end
end
