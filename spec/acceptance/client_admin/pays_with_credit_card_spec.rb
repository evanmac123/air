require 'acceptance/acceptance_helper'

feature 'Pays with credit card' do
  before do
    Stripe::Charge.stubs(:create).returns {Stripe::Charge.new}

    @client_admin = FactoryGirl.create(:client_admin)
    @demo = @client_admin.demo
    @stripe_script_url = "https://checkout.stripe.com/v2/checkout.js"
  end

  def payment_form_selector(balance)
    "form[action='#{client_admin_balance_path(balance)}']"   
  end

  def expect_payment_script_for_amount(balance)
    expected_script_attributes = {
      "src"              => @stripe_script_url,
      "data-key"         => STRIPE_PUBLIC_KEY,
      "data-amount"      => balance.amount,
      "data-name"        => "H.Engage",
      "data-description" => "Payment to H.Engage"
    }
    script_selector = "script" + expected_script_attributes.map{|k,v| "[#{k}='#{v}']"}.join

    page.find("#{payment_form_selector(balance)} #{script_selector}").should be_present
  end

  def expect_balance_description(balance)
    dollars = balance.amount / 100
    cents = sprintf("%02u", balance.amount % 100)
    date = balance.created_at.strftime("%x")

    expect_content ("Outstanding balance: $#{dollars}.#{cents}")
    expect_content ("Billed: #{date}")
  end

  def expect_no_payments_link
    expect_no_content "Payments"
    page.all("a[href='#{new_client_admin_payment_path}']").should have(0).links
  end

  scenario "when they have no balances" do
    visit client_admin_path(as: @client_admin)
    expect_no_payments_link
  end

  context "when they have no outstanding balances" do
    before do
      FactoryGirl.create(:balance, :paid, demo: @demo)
    end

    it "should not show the link" do
      visit client_admin_path(as: @client_admin)
      expect_no_payments_link
    end

    it "should have a cheerful message to that effect on the payments page" do
      visit new_client_admin_payment_path(as: @client_admin)
      expect_content "You've got no outstanding balances. How nice!"
    end
  end

  context "when they have an outstanding balance" do
    before do
      3.times do |n|
        FactoryGirl.create(:balance, demo: @demo, amount: (n+1) * 1000)
      end

      FactoryGirl.create(:balance, :paid, demo: @demo)
    end

    it "should show the link to balances" do
      visit client_admin_path(as: @client_admin)
      click_link "Payments"
      should_be_on new_client_admin_payment_path
    end

    scenario "sees a form for each outstanding balance they have outstanding, and only those" do
      visit new_client_admin_payment_path(as: @client_admin)
      [1000,2000,3000].each do |amount|
        balance = Balance.find_by_amount(amount)
        expect_payment_script_for_amount balance
        expect_balance_description balance
      end

      within '.content' do
        page.all('form').should have(3).payment_forms
      end
    end
  end
end
