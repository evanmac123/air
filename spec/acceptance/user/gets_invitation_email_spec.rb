require 'acceptance/acceptance_helper'

include EmailHelper

feature 'User gets invitation email' do
  def expect_email_content(expected_content)
    open_email(@user.email)
    expect(current_email.body).to include(expected_content)
  end

  def expect_no_email_content(unexpected_content)
    open_email(@user.email)
    expect(current_email.body).not_to include(unexpected_content)
  end

  def expect_subject(expected_subject)
    open_email(@user.email)
    expect(current_email.subject).to eq(expected_subject)
  end

  before(:each) do
    @demo = FactoryBot.create(:demo, :with_email, allow_unsubscribes: true)
    @user = FactoryBot.create(:user, demo: @demo, name: "Dude Duderson")
    @referrer = FactoryBot.create(:user, demo: @demo, name: "Andy McReferrer")
  end

  context "from a demo that has a reply email name set" do
    before(:each) do
      @demo.update_attributes(custom_reply_email_name: "The Team At BigCo")
      @user.invite
    end

    it "should use that name in the From: field" do
      open_email(@user.email)

      expect(current_email.from).to eq([@demo.email])
      expect(current_email[:from].display_names).to eq(["The Team At BigCo"])
    end
  end

  context "from a demo that has no reply email name set" do
    before(:each) do
      expect(@demo.custom_reply_email_name).to be_blank
      @user.invite
    end

    it "should use the name of the game in the From: field" do
      open_email(@user.email)

      expect(current_email.from).to eq([@demo.email])
      expect(current_email[:from].display_names).to eq([@demo.name])
    end
  end

  context "and there's a referrer" do
    context "and there's a custom subject-with-referrer" do
      it "should use that" do
        @user.invite(@referrer)
        expect_subject "#{@referrer.name} invited you to join #{@demo.name}"
      end
    end
  end

  it "should get a footer with our address and an unsubscribe link, but no link to account settings" do
    @user.invite

    open_email(@user.email)
    expect(current_email.body).to include("Our Mailing Address is")

    visit_in_email "unsubscribe"
    should_be_on new_unsubscribe_path

    expect_no_email_content email_account_settings_link
  end
end
