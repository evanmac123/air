# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  include ClientAdmin::TilesHelper

  def initialize(method_name = nil, *args)
    super.tap do
      unless headers["X-SMTPAPI"].present?
        set_default_x_smtpapi_headers(method_name)
      end
    end
  end

  def set_x_smtpapi_headers(category:, unique_args:)
    headers["X-SMTPAPI"] = {
      category: category,
      unique_args: unique_args
    }.to_json
  end

  private

    def set_default_x_smtpapi_headers(mailer_method)
      headers["X-SMTPAPI"] = {
        category: "#{self.class.name}##{mailer_method}"
      }.to_json
    end
end
