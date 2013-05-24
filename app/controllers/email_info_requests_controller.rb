require 'email_info_request'

class EmailInfoRequestsController < ApplicationController
  skip_before_filter :authorize
  skip_before_filter :force_ssl

  def create
    hash = {
      email:   params[:contact_email],
      name:    params[:contact_name],
      comment: params[:contact_comment],
      role:    params[:contact_role],
      size:    params[:contact_size],
      company: params[:contact_company]
    }

    request = EmailInfoRequest.create!(hash)
    request.notify_the_ks_of_demo_request

    if params[:silent]
      render inline: ''
    end
  end
end
