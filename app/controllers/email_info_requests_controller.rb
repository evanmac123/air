class EmailInfoRequestsController < ApplicationController
  skip_before_filter :authorize
  skip_before_filter :force_ssl
  before_filter :force_no_ssl

  def create
    hash = {email: params[:contact_email],
            name: params[:contact_name],
            phone: params[:contact_phone],
            comment: params[:contact_comment]}
    EmailInfoRequest.create!(hash)
  end
end
