class Admin::ExploreDigestsController < AdminBaseController
  def new
    @explore_digest = ExploreDigest.new
  end

  def index
    @explore_digests = ExploreDigest.scoped
  end

  def create
    @explore_digest = ExploreDigest.create
    @explore_digest.post_to_redis(params[:defaults], params[:features])

    redirect_to edit_admin_explore_digest_path(@explore_digest)
  end

  def edit
    @explore_digest = ExploreDigest.find(params[:id])
  end

  def update
    @explore_digest = ExploreDigest.find(params[:id])
    @explore_digest.update_attributes(explore_digest_params)
    @explore_digest.post_to_redis(params[:defaults], params[:features])

    redirect_to edit_admin_explore_digest_path(@explore_digest)
  end

  def deliver
    @explore_digest = ExploreDigest.find(params[:explore_digest_id])
    @explore_digest.validate

    if @explore_digest.errors.any?
      render json: {status: 'failure', errors: @explore_digest.errors.full_messages.join(", ")}
    else
      if test_digest?
        @explore_digest.deliver_test_digest!(current_user)
        render :edit
      elsif @explore_digest.approved
        @explore_digest.deliver_digest!
        flash[:success] = "Digest delivered"
        redirect_to admin_explore_digests_path
      else
        render json: {status: 'failure', errors: "Digest not approved"}
      end
    end
  end

  private

    def test_digest?
      params[:test_digest] == "true"
    end

    def explore_digest_params
      params.require(:explore_digest).permit(:approved)
    end
end
