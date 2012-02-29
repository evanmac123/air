class Admin::ReportsController < ApplicationController
  
  def show
    @demo = Demo.find(params[:demo_id])
  end

  
end
