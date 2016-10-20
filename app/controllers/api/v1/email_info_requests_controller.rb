class Api::V1::EmailInfoRequestsController < ApplicationController
  skip_before_filter :authorize

  def create
    request = EmailInfoRequest.new(permitted_params)
    request.notify if request.save

    render json: { success: request.persisted?, user_onboarding: request.attributes }
  end

  protected

  def permitted_params
    params[:request].permit!
  end
end
