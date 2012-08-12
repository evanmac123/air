require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "User Accepts Invitation" do

  before(:each) do
    @user = FactoryGirl.create :user
  end

  scenario "User gets logged in only when accepting invitation, not when at acceptance form" do
    visit invitation_page(@user)
    visit activity_page
    should_be_on(signin_page)
    visit invitation_page(@user)


    fill_in_required_invitation_fields
    click_button 'Join the game'
    should_be_on(activity_page)
  end

  context "when there is no client name specified for the demo" do
    before(:each) do
      @user.demo.client_name.should_not be_present
    end

    it "should not say \"Sponsored by\"" do
      visit invitation_page(@user)
      expect_no_content "Sponsored by"
    end
  end

  context "when there is a client name specified for the demo" do
    before(:each) do
      @user.demo.update_attributes(client_name: "BigCorp")
    end

    it "should say who sponsored the game" do
      visit invitation_page(@user)
      expect_content "Sponsored by: BigCorp"
    end
  end
end
