class Admin::LocationsController < AdminBaseController

  before_filter :find_demo_by_demo_id

  def index
    @locations = @demo.locations.alphabetical
    @location = Location.new
  end

  def create
    @demo.locations.create!(params[:location])
    redirect_to :back
  end

  def destroy
    Location.find(params[:id]).destroy
    redirect_to :back
  end
end
