class EmailInfoRequestsController < ApplicationController
  skip_before_filter :authenticate
  skip_before_filter :force_ssl
  before_filter :force_no_ssl

  def create
    EmailInfoRequest.create!(params[:email])
    render :text => ''
  end
end
