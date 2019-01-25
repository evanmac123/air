# frozen_string_literal: true

class Api::V1::RequestAccountController < Api::ApiController
  skip_before_action :verify_authenticity_token

  def create
    account_request = User::AccountRequestService.new(request_account_params)

    response = if account_request.send_request
      { status: "success", message: "Account successfully requested. Someone from our team will reach out to you in the next 24 hours to finalize the setup." }
    else
      { status: "failure", message: account_request.error_message }
    end
    render json: response
  end

  private
    def request_account_params
      params.require(:account).permit(:name, :email, :phone_number, :company_name)
    end
end
