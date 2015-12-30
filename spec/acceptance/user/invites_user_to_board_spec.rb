require 'acceptance/acceptance_helper'

feature 'User invites user to board' do
  AUTOCOMPLETE_STATUS = {
    click: "CLICK ON THE PERSON YOU WANT TO INVITE:",
    hm: "HMMM...NO MATCH",
    sent: "Invitation sent - thanks for sharing!",
    not_found: "User not found."
  }


  before(:each) do
    @demo1 = FactoryGirl.create(:demo, :name => "Bratwurst")
    @demo2 = FactoryGirl.create(:demo, :name => "Gleason")

    @user = FactoryGirl.create(:user, :claimed, demo: @demo1, name: "Cool guy", slug: "cool_guy", password: "foobar")
    signin_as @user, 'foobar'

    @user0 = FactoryGirl.create(:user, :unclaimed, :name => "Joining Now 1", :demo => @demo1, :email => "angel@hopper.com", :slug => "angelfire", :sms_slug => "angelfire")
    @user1 = FactoryGirl.create(:claimed_user, :name => "mad house",      :demo => @demo1, :email => "manly@hopper.com", :slug => "beau", :sms_slug => "beau")
    @user2 = FactoryGirl.create(:claimed_user, :name => "Lucy",           :demo => @demo1, :email => "boob@hopper.com", :slug => "lou", :sms_slug => "lou")
    @user3 = FactoryGirl.create(:claimed_user, :name => "Strange",        :demo => @demo1, :email => "surround@hopper.com", :slug => "think", :sms_slug => "think")
    @user4 = FactoryGirl.create(:claimed_user, :name => "Parking Lot",    :demo => @demo1, :email => "chevo@hopper.com", :slug => "master", :sms_slug => "master")
    @user5 = FactoryGirl.create(:claimed_user, :name => "Lucy",           :demo => @demo2, :email => "boob@biker.com", :slug => "sterling", :sms_slug => "sterling")
    @user6 = FactoryGirl.create(:claimed_user, :name => "Brewski",        :demo => @demo2, :email => "three@biker.com", :slug => "gold", :sms_slug => "gold")
    @user7 = FactoryGirl.create(:claimed_user, :name => "Latino",         :demo => @demo2, :email => "four@biker.com", :slug => "nutcase", :sms_slug => "nutcase")
    @user8 = FactoryGirl.create(:user, :unclaimed, :name => "Va Va Va Voom",  :demo => @demo2, :email => "seven@biker.com", :slug => "sixpack", :sms_slug => "sixpack")
    @user9 = FactoryGirl.create(:claimed_user, :name => "Joining Now 2",  :demo => @demo2, :email => "angel@biker.com", :slug => "damnation", :sms_slug => "damnation")
  
    visit activity_path
  end

  describe "search by name" do
    describe "search for unclaimed user from board" do
      before(:each) do
        fill_in "autocomplete", with: "join"
      end

      it "should return user", js: true do
        autocomplete_status AUTOCOMPLETE_STATUS[:click]
        should_find_user @user0.name
        found_users_count.should == 1
        should_have_invite_button @user0
      end  

      context "invite unclaimed user" do
        before(:each) do
          page.find(".single_click_invite").click
        end

        it "should send invitation", js: true do
          should_send_email @user0, @user, @demo1
        end
        
        it "should send ping", js: true do
          should_send_friend_invitation_ping @user0
        end
      end
    end

    describe "search for claimed user from board" do
      before(:each) do
        fill_in "autocomplete", with: "mad"
      end

      it "should return user without invite button", js: true do
        autocomplete_status AUTOCOMPLETE_STATUS[:click]
        should_find_user @user1.name
        found_users_count.should == 1
        should_not_have_invite_button @user0
        expect_content "(already participating)"
      end 
    end

    describe "search for unclaimed user from other board" do
      before(:each) do
        fill_in "autocomplete", with: "Va Va"
      end

      it "should not return user", js: true do
        autocomplete_status AUTOCOMPLETE_STATUS[:hm]
        should_find_no_user "Va Va Va Voom"
        found_users_count.should == 0
      end
    end
  end

  describe "search by email" do
    describe "search for unclaimed user from board" do
      before(:each) do
        fill_in "autocomplete", with: @user0.email
      end

      it "should return user", js: true do
        autocomplete_status AUTOCOMPLETE_STATUS[:click]
        should_find_user @user0.name
        found_users_count.should == 1
        should_have_invite_button @user0
      end

      context "invite unclaimed user" do
        before(:each) do
          page.find(".single_click_invite").click
        end

        it "should send invitation", js: true do
          should_send_email @user0, @user, @demo1
        end
        
        it "should send ping", js: true do
          should_send_friend_invitation_ping @user0
        end
      end
    end

    describe "search for claimed user from board" do
      before(:each) do
        fill_in "autocomplete", with: @user1.email
      end

      it "should return user without invite button", js: true do
        autocomplete_status AUTOCOMPLETE_STATUS[:click]
        should_find_user @user1.name
        found_users_count.should == 1
        should_not_have_invite_button @user1
        expect_content "(already participating)"
      end 
    end

    describe "search for unclaimed user from other board" do
      before(:each) do
        fill_in "autocomplete", with: @user8.email
      end

      it "should return user", js: true do
        autocomplete_status AUTOCOMPLETE_STATUS[:click]
        should_find_user @user8.email
        found_users_count.should == 1
      end

      context "invite user" do
        before(:each) do
          page.find(".single_click_invite").click
          @potential_user = PotentialUser.last
        end

        it "should create potential user with entered email", js: true do
          @potential_user.email.should == @user8.email
        end

        it "should send invitation", js: true do
          should_send_email @user8, @user, @demo1
        end
        
        it "should send ping", js: true do
          should_send_friend_invitation_ping @potential_user
        end
      end
    end

    describe "search for unregistered person" do
      before(:each) do
        fill_in "autocomplete", with: "new@person.com"
      end

      it "should return card with email", js: true do
        autocomplete_status AUTOCOMPLETE_STATUS[:click]
        should_find_user "new@person.com"
        found_users_count.should == 1
      end

      scenario "invite user", js: true do
        page.find(".single_click_invite").click

        potential_user = PotentialUser.last
        should_send_email potential_user, @user, @demo1
      end
    end
  end


  def autocomplete_status status
    page.find("#autocomplete_status").should have_content status
  end

  def should_find_user name
    within ".single_suggestion" do
      page.should have_content name
    end
  end

  def should_find_no_user name
    page.all(".single_suggestion", text: name).count.should == 0
  end

  def found_users_count
    page.all(".single_suggestion").count
  end

  def should_have_invite_button user
    page.find("#invitee_id[value='#{user.id}']", visible: false).should be_present
  end

  def should_not_have_invite_button user
    page.all("#invitee_id[value='#{user.id}']").count.should == 0
  end

  def should_send_email invitee, referrer, demo
    autocomplete_status AUTOCOMPLETE_STATUS[:sent]
    crank_dj_clear

    open_email invitee.email
    current_email.to_s.should have_content "#{referrer.name} invited you to"
    current_email.to_s.should have_content " join the #{demo.name}"
  end

  def should_send_friend_invitation_ping user
    FakeMixpanelTracker.clear_tracked_events
    crank_dj_clear
    event = "Email Sent"
    properties = {email_type: "Friend Invitation"}.merge user.data_for_mixpanel 
    FakeMixpanelTracker.should have_event_matching(event, properties)
  end


end
