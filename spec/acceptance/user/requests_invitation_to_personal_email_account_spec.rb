require 'acceptance/acceptance_helper'
#FIXME remove this code as this functionality is no longer used as of 2016-07-26

feature "Spiderman offers ten dollars to anyone who can name all the ways to join HEngage" do
    include EmailSpec::Helpers
    include EmailSpec::Matchers

  before(:each) do
    @claim_code = 'abcde'
    @leahs_personal_email = 'leah@eatyourshorts.com'
    @leahs_corporate_email = 'leah@hot.com'
    @leah = FactoryGirl.create(:user, email: @leahs_corporate_email, claim_code: @claim_code)
  end
  
  scenario "Juan has an SMS account (no email associated), then texts us his personal email" do
    juan_phone = '+12083665544'
    personal_email = 'jones@yall.biz'
    juan = FactoryGirl.create(:claimed_user, email: nil, official_email: "yada@yadd.con", phone_number: juan_phone)
    mo_sms(juan_phone, personal_email)
    crank_dj_clear
    open_email(personal_email).subject.should include("Your invitation to join the #{juan.demo.name}")
    juan.reload.email.should == personal_email
    juan.overflow_email.should be_blank
  end

  scenario "Juan has an SMS account(with corporate email associated), then texts us his personal email" do
    juan_phone = '+12083665544'
    personal_email = 'jones@yall.biz'
    corporate_email = 'mutherfucka@big-corporation.com'
    juan = FactoryGirl.create(:claimed_user, email: corporate_email, phone_number: juan_phone)
    mo_sms(juan_phone, personal_email)
    crank_dj_clear
    open_email(personal_email).subject.should include("Your invitation to join the #{juan.demo.name}")
    juan.reload.email.should == personal_email
    juan.overflow_email.should == corporate_email 
  end
end
