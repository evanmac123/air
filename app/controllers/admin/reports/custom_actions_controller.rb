class Admin::Reports::CustomActionsController < ApplicationController

  def show
    @demo = Demo.find(params[:demo_id])
    
    @tags = Tag.all

  end

end
