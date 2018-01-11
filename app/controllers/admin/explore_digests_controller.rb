class Admin::ExploreDigestsController < AdminBaseController
  def new
    @explore_digest = ExploreDigest.new
  end

  def index
    @explore_digests = ExploreDigest.all
  end

  def create
    @explore_digest = ExploreDigest.create
    @explore_digest.post_to_redis(params[:defaults], params[:features])

    if @explore_digest.errors.any?
      render json: {status: 'failure', errors: @explore_digest.errors.full_messages.join(", ")}
    else
      render json: {status: 'success', explore_digest: @explore_digest.attributes }
    end
  end

  def edit
    @explore_digest = ExploreDigest.find(params[:id])
  end

  def update
    @explore_digest = ExploreDigest.find(params[:id])
    @explore_digest.update_attributes(explore_digest_params)
    @explore_digest.post_to_redis(params[:defaults], params[:features])

    if @explore_digest.errors.any?
      render json: {status: 'failure', errors: @explore_digest.errors.full_messages.join(", ")}
    else
      render json: {status: 'success', explore_digest: @explore_digest.attributes }
    end
  end

  def deliver
    @explore_digest = ExploreDigest.find(params[:explore_digest_id])
    @explore_digest.validate(targeted_digest_params)

    if @explore_digest.errors.any?
      render json: {status: 'failure', errors: @explore_digest.errors.full_messages.join(", ")}
    else
      if test_digest?
        @explore_digest.deliver_test_digest!(current_user)
        render :edit
      elsif @explore_digest.approved
        if targeted_digest?
          @explore_digest.deliver_targeted_digest!
        else
          @explore_digest.deliver_digest!
        end

        render json: {status: 'success', flash: "Digest delivered"}
      else
        render json: {status: 'failure', errors: "Digest not approved"}
      end
    end
  end

  private

    def test_digest?
      params[:test_digest] == "true"
    end

    def targeted_digest?
      params[:targeted_digest][:send] == "true"
    end

    def explore_digest_params
      params.require(:explore_digest).permit(:approved)
    end

    def targeted_digest_params
      params.require(:targeted_digest).permit(:send, :users)
    end
end
