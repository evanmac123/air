class Users::PingsController < ApplicationController
  def create 
    page_name = params[:page_name]
    current_user.ping_page(page_name)
    render :text => ''
  end
end
