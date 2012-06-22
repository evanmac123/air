require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "User with SMS Account Upgrades to web account" do
    include EmailSpec::Helpers
    include EmailSpec::Matchers

  before(:each) do
    @lolita_phone = "+12083954227"
    @juan_phone = "+12084663723"
    @corporate_email = "special@needs.org"
    @personal_email = "gloss_black@james.net"
    @lolita_with_email = FactoryGirl.create(:claimed_user, email: @corporate_email, phone_number: @lolita_phone)
    @juan_without_email = FactoryGirl.create(:claimed_user, email: nil, phone_number: @juan_phone)

  end

  scenario "Juan (sms account) with no corporate email creates web account via personal email"  do
    mo_sms(@juan_phone, @personal_email)
    crank_dj_clear 
    open_email(@personal_email).subject.should include('Ready to play?')
  end

  scenario "Lolita (sms account) with corporate email creates web account via corporate email" do
    mo_sms(@lolita_phone, @corporate_email) 
    crank_dj_clear 
    open_email(@corporate_email).subject.should include('Ready to play?')
  end
  
  scenario "Lolita (sms account) with corporate email creates web account via personal email" do
    mo_sms(@lolita_phone, @personal_email)
    crank_dj_clear 
    open_email(@personal_email).subject.should include('Ready to play?')
  end

end
