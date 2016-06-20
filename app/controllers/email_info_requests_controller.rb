require 'email_info_request'

class EmailInfoRequestsController < ApplicationController
  skip_before_filter :authorize
  skip_before_filter :force_ssl

  def create
    hash = {
      email:   params[:contact_email].to_s,
      name:    params[:contact_name].to_s,
      comment: params[:contact_comment].to_s,
      role:    params[:contact_role].to_s,
      size:    params[:contact_size].to_s,
      company: params[:contact_company].to_s,
      source:  params[:source].to_s
    }

    request = EmailInfoRequest.create!(hash)
    request.notify_the_ks_of_demo_request

    if params[:silent]
      render inline: ''
    end
  end
end
