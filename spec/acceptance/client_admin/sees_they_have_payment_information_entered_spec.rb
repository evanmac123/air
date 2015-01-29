require 'acceptance/acceptance_helper'

feature 'Sees they have payment information already entered' do
  before do
    @client_admin = FactoryGirl.create(:client_admin)
    @billing_information = FactoryGirl.create(:billing_information, user: @client_admin)
  end

  scenario 'when they go to the billing information page' do
    visit client_admin_billing_information_path(as: @client_admin)

    page.should have_content("#{@billing_information.issuer} card **** **** **** #{@billing_information.last_4}, valid until #{@billing_information.expiration_month}/#{@billing_information.expiration_year}")
    page.should have_content("To reset this so you can enter new billing information, please contact support@airbo.com")
  end
end
