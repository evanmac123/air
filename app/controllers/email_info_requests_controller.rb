class EmailInfoRequestsController < ApplicationController
  skip_before_filter :authenticate

  def create
    @email = params[:email].blank? ?
               nil :
               params[:email]
    @name  = params[:name].blank? ?
               nil :
               params[:name]

    EmailInfoRequest.create!(:name => @name, :email => @email) if (@name && @email)
  end
end
