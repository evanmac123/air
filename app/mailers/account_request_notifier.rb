# frozen_string_literal: true

class AccountRequestNotifier < ApplicationMailer
  default from: "team@airbo.com"
  helper :email

  def notify_customer_success(account_request)
    @account_request = JSON.parse(account_request)

    mail(
      from: "Account Request<support@airbo.com>",
      to: "support@airbo.com",
      subject: "New Account Request from #{@account_request['email']}"
    )
  end
end
