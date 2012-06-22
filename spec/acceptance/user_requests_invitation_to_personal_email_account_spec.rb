require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Spiderman offers ten dollars to anyone who can name all the ways to join H Engage" do
    include EmailSpec::Helpers
    include EmailSpec::Matchers

  before(:each) do
    @claim_code = 'abcde'
    @leahs_personal_email = 'leah@eatyourshorts.com'
    @leahs_corporate_email = 'leah@hot.com'
    @leah = FactoryGirl.create(:user, email: @leahs_corporate_email, claim_code: @claim_code)
  end

  scenario "Leah emails us her claim code from her personal email"  do
    email_originated_message_received(@leahs_personal_email, 'Some Such Subject', @claim_code)
    crank_dj_clear
    open_email(@leahs_personal_email).subject.include? 'Ready to play?'   
    @leah.reload.email.should == @leahs_personal_email
    @leah.overflow_email.should == @leahs_corporate_email
  end

  scenario "Leah emails us her claim code from her corporate email"  do
    email_originated_message_received(@leahs_corporate_email, 'Some Such Subject', @claim_code)
    crank_dj_clear
    open_email(@leahs_corporate_email).subject.include? 'Ready to play?'   
    @leah.reload.email.should == @leahs_corporate_email
    @leah.overflow_email.should be_blank
  end

end
