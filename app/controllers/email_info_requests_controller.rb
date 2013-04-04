require 'email_info_request'

class EmailInfoRequestsController < ApplicationController
  skip_before_filter :authorize
  skip_before_filter :force_ssl

  def create
    hash = {email: params[:contact_email],
            name: params[:contact_name],
            phone: params[:contact_phone],
            comment: params[:contact_comment]}
    request = EmailInfoRequest.create!(hash)
    request.notify_the_ks_of_demo_request
  end
end
