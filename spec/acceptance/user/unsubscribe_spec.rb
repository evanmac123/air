require 'acceptance/acceptance_helper'

feature "Leah unsubscribes" do
  before(:each) do
    Unsubscribe.delete_all
    @leah = FactoryGirl.create(:user, name: 'Leah Eckles')
    @token = EmailLink.generate_token(@leah)
    @unsubscribe_url = new_unsubscribe_path({user_id: @leah.id, token: @token})
    @reason = "I'm just having way too much fun on YouTube"
  end

  it "should have a link at the bottom of the email that points to the unsubscribe page" do
    email = Mailer.easy_in(@leah)
    [email.html_part.body, email.text_part.body].each do |body|
      body.should include @unsubscribe_url.gsub("&", "&amp;")
    end
  end

  it "should create an unsubscribe" do
    Unsubscribe.count.should == 0
    visit @unsubscribe_url
    #fill_in 'unsubscribe_reason', with: @reason 
    click_button 'Unsubscribe'
    page.should have_content 'You have been unsubscribed'
    Unsubscribe.count.should == 1
    a = Unsubscribe.first
    a.user_id.should == @leah.id
    #a.reason.should == @reason
  end

  context "when Leah is unclaimed" do
    before do
      @leah.should_not be_claimed
    end

    it "should not have a link to the account preferences page" do
      visit @unsubscribe_url
      expect_no_content "change your contact preferences"
    end
  end

  context "when Leah is claimed" do
    before do
      @leah.update_attributes(accepted_invitation_at: Time.now)
      has_password @leah, 'foobar'
      signin_as @leah, 'foobar'
    end

  end
end
