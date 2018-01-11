require 'spec_helper'

describe ApplicationMailer do
  class FakeMailer < ApplicationMailer
    def notify_with_default_headers(user: user)
      mail to: user.email,
        from: "admin@example.com",
        subject: "Set Default Headers",
        body: 'Fake Mailer'
    end

    def notify_with_custom_headers(user: user, category: "Custom", unique_args: {})
      set_x_smtpapi_headers(category: category, unique_args: unique_args)
      mail to: user.email,
        from: "admin@example.com",
        subject: "Set Default Headers",
        body: 'Fake Mailer'
    end
  end

  let(:user) { FactoryBot.build(:user) }

  describe "on initialize it calls #set_default_x_smtpapi_headers" do
    it "sets deault X-SMTPAPI headers if they are not already set" do
      mail = FakeMailer.notify_with_default_headers(user: user)
      default_x_smtpapi_headers = JSON.parse(mail.header["X-SMTPAPI"].value)

      expect(default_x_smtpapi_headers["category"]).to eq("FakeMailer#notify_with_default_headers")
    end

    it "respects already set X-SMTPAPI headers and does not add additional headers" do
      mail = FakeMailer.notify_with_custom_headers(user: user)
      custom_x_smtpapi_headers = JSON.parse(mail.header["X-SMTPAPI"].value)

      expect(custom_x_smtpapi_headers["category"]).to eq("Custom")
    end
  end

  describe "#set_x_smtpapi_headers" do
    it "sets :category and :unique_args for X-SMTPAPI header" do
      category = "A Custom Category"
      unique_args = { user_email: user.email, other_stuff: true }
      mail = FakeMailer.notify_with_custom_headers(user: user, category: category, unique_args: unique_args)

      custom_x_smtpapi_headers = JSON.parse(mail.header["X-SMTPAPI"].value)

      expect(custom_x_smtpapi_headers["category"]).to eq(category)
      expect(custom_x_smtpapi_headers["unique_args"]["user_email"]).to eq(user.email)
      expect(custom_x_smtpapi_headers["unique_args"]["other_stuff"]).to eq(true)
    end
  end
end
