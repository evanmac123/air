class EmailInfoRequestsController < ApplicationController
  skip_before_filter :authenticate

  def create
    @email = params[:email].blank? ?
               nil :
               params[:email]

    EmailInfoRequest.create!(:email => @email) if @email
  end
end
