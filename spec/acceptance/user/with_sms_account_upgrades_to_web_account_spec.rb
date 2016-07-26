require 'acceptance/acceptance_helper'

#FIXME remove this spec as this signup via SMS functionality is no longer used

feature "User with SMS Account Upgrades to web account" do
    include EmailSpec::Helpers
    include EmailSpec::Matchers

  before(:each) do
    @already_taken_email = 'sweeeeeeeeeeeeeeeet@babynectar.com'
    FactoryGirl.create(:claimed_user, email: @already_taken_email)
    @lolita_phone = "+12083954227"
    @juan_phone = "+12084663723"
    @corporate_email = "special@needs.org"
    @personal_email = "gloss_black@james.net"
    @lolita_with_email = FactoryGirl.create(:claimed_user, email: @corporate_email, phone_number: @lolita_phone)
    @juan_without_email = FactoryGirl.create(:claimed_user, email: nil, official_email: "blase@blase.com", phone_number: @juan_phone)

  end

  scenario "Juan (sms account) with no corporate email creates web account via personal email and clicks through to set password"  do
    mo_sms(@juan_phone, @personal_email)
    crank_dj_clear 
    open_email(@personal_email).subject.should include("Your invitation to join the #{@juan_without_email.demo.name}")
    regex = /password/
    click_email_link_matching(regex)
    page.should have_content 'Choose a Password'
  end

  scenario "Lolita (sms account) with corporate email creates web account via corporate email" do
    mo_sms(@lolita_phone, @corporate_email) 
    crank_dj_clear 
    open_email(@corporate_email).subject.should include("Your invitation to join the #{@lolita_with_email.demo.name}")
  end
  
  scenario "Lolita (sms account) with corporate email creates web account via personal email" do
    mo_sms(@lolita_phone, @personal_email)
    crank_dj_clear 
    open_email(@personal_email).subject.should include("Your invitation to join the #{@lolita_with_email.demo.name}")
  end

  scenario "Juan (sms account) accidentally sends a taken email" do
    mo_sms(@juan_phone, @already_taken_email)
    crank_dj_clear
    expected_text = "The email #{@already_taken_email} has already been taken."
    expect_mt_sms(@juan_phone, expected_text)
    @juan_without_email.reload.email.should be_blank
  end

end
