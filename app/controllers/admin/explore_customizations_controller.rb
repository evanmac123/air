class Admin::ExploreCustomizationsController < AdminBaseController
  def new
  end

  def create
    $redis.hset("explore_customization", params[:key], params[:value])

    render json: { key: "explore_customization", value:  $redis.hget("explore_customization", params[:key]) }
  end
end
