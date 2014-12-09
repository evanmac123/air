class Admin::ExploreDigestsController < AdminBaseController
  require Rails.root.join("app/forms/explore_digest_form")

  def new
    @explore_digest_form = NullExploreDigestForm.new
  end

  def create
    @explore_digest_form = if params[:commit] == 'Send real digest'
                             ExploreDigestForm.new(params[:explore_digest_form])
                           else
                             ExploreDigestTestForm.new(params[:explore_digest_form], current_user)
                           end

    if @explore_digest_form.valid?
      @explore_digest_form.send_digest!
    else
      flash[:failure] = "Couldn't send digest: #{@explore_digest_form.errors.full_messages.join(', ')}"
    end

    render :new
  end
end
