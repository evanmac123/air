class Admin::Reports::PointsController < ApplicationController

  def show
    @demo = Demo.find(params[:demo_id])
  end
  
end
