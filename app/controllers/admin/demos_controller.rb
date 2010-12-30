class Admin::DemosController < ApplicationController
  def new
    @demo = Demo.new
  end

  def create
    @demo = Demo.new(params[:demo])
    @demo.save
    flash[:success] = "Demo created."
    redirect_to admin_demo_path(@demo)
  end

  def show
    @demo    = Demo.find(params[:id])
    @players = @demo.players
  end
end
