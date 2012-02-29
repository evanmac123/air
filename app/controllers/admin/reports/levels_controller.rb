class Admin::Reports::LevelsController < ApplicationController

  def show
    @demo = Demo.find(params[:demo_id])
  end
end
