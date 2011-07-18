class EmailInfoRequestsController < ApplicationController
  skip_before_filter :authenticate

  def create
    EmailInfoRequest.create!(params[:email])
  end
end
