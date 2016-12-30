require 'acceptance/acceptance_helper'

feature "Leah unsubscribes" do
  before(:each) do
    Unsubscribe.delete_all
    @leah = FactoryGirl.create(:user, name: 'Leah Eckles')
    @token = EmailLink.generate_token(@leah)
    @unsubscribe_url = new_unsubscribe_path({user_id: @leah.id, token: @token})
    @reason = "I'm just having way too much fun on YouTube"
  end

  it "should create an unsubscribe" do
    expect(Unsubscribe.count).to eq(0)
    visit @unsubscribe_url
    #fill_in 'unsubscribe_reason', with: @reason 
    click_button 'Unsubscribe'
    expect(page).to have_content 'You have been unsubscribed'
    expect(Unsubscribe.count).to eq(1)
    a = Unsubscribe.first
    expect(a.user_id).to eq(@leah.id)
    #a.reason.should == @reason
  end

  context "when Leah is unclaimed" do
    before do
      expect(@leah).not_to be_claimed
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
