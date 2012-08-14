require 'acceptance/acceptance_helper'

feature 'User gets invitation email' do
  before(:each) do
    @demo = FactoryGirl.create(:demo, :with_email)
    @user = FactoryGirl.create(:user, demo: @demo)
  end

  context "from a demo that has a reply email name set" do
    before(:each) do
      @demo.update_attributes(custom_reply_email_name: "The Team At BigCo")
      @user.invite(nil, :style => EmailStyling.new(""))
      crank_dj_clear
    end

    it "should use that name in the From: field" do
      open_email @user.email
      current_email.to_s.should include("From: The Team At BigCo <#{@demo.email}>")
    end
  end

  context "from a demo that has no reply email name set" do
    before(:each) do
      @demo.custom_reply_email_name.should be_blank
      @user.invite(nil, :style => EmailStyling.new(""))
      crank_dj_clear
    end

    it "should use the name of the game in the From: field" do
      open_email @user.email
      current_email.to_s.should include("From: #{@demo.name} <#{@demo.email}>")
    end
  end
end
