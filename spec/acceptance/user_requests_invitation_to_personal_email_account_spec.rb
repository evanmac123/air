require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Spiderman offers ten dollars to anyone who can name all the ways to join H Engage" do
    include EmailSpec::Helpers
    include EmailSpec::Matchers

  before(:each) do
    @claim_code = 'abcde'
    @leahs_personal_email = 'leah@eatyourshorts.com'
    @leah = FactoryGirl.create(:user, email: 'leah@hot.com', claim_code: @claim_code)
  end

  scenario "Leah emails us her employee ID and we send her an invite"  do
    email_originated_message_received(@leahs_personal_email, 'Some Such Subject', @claim_code)
    crank_dj_clear
    open_email(@leahs_personal_email).subject.include? 'Ready to play?'   
  end
end
