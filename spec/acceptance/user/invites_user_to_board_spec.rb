require 'acceptance/acceptance_helper'

xfeature 'User invites user to board', broken: true do
  AUTOCOMPLETE_STATUS = {
    click: "CLICK ON THE PERSON YOU WANT TO INVITE:",
    hm: "HMMM...NO MATCH",
    sent: "Invitation sent - thanks for sharing!",
    not_found: "User not found."
  }


  before(:each) do
    @demo1 = FactoryBot.create(:demo, :name => "Bratwurst")
    @demo2 = FactoryBot.create(:demo, :name => "Gleason")

    @user = FactoryBot.create(:user, :claimed, demo: @demo1, name: "Cool guy", slug: "cool_guy", password: "foobar")

    @user0 = FactoryBot.create(:user, :unclaimed, :name => "Joining Now 1", :demo => @demo1, :email => "angel@hopper.com", :slug => "angelfire", :sms_slug => "angelfire")
    @user1 = FactoryBot.create(:claimed_user, :name => "mad house",      :demo => @demo1, :email => "manly@hopper.com", :slug => "beau", :sms_slug => "beau")
    @user2 = FactoryBot.create(:claimed_user, :name => "Lucy",           :demo => @demo1, :email => "boob@hopper.com", :slug => "lou", :sms_slug => "lou")
    @user3 = FactoryBot.create(:claimed_user, :name => "Strange",        :demo => @demo1, :email => "surround@hopper.com", :slug => "think", :sms_slug => "think")
    @user4 = FactoryBot.create(:claimed_user, :name => "Parking Lot",    :demo => @demo1, :email => "chevo@hopper.com", :slug => "master", :sms_slug => "master")
    @user5 = FactoryBot.create(:claimed_user, :name => "Lucy",           :demo => @demo2, :email => "boob@biker.com", :slug => "sterling", :sms_slug => "sterling")
    @user6 = FactoryBot.create(:claimed_user, :name => "Brewski",        :demo => @demo2, :email => "three@biker.com", :slug => "gold", :sms_slug => "gold")
    @user7 = FactoryBot.create(:claimed_user, :name => "Latino",         :demo => @demo2, :email => "four@biker.com", :slug => "nutcase", :sms_slug => "nutcase")
    @user8 = FactoryBot.create(:user, :unclaimed, :name => "Va Va Va Voom",  :demo => @demo2, :email => "seven@biker.com", :slug => "sixpack", :sms_slug => "sixpack")
    @user9 = FactoryBot.create(:claimed_user, :name => "Joining Now 2",  :demo => @demo2, :email => "angel@biker.com", :slug => "damnation", :sms_slug => "damnation")

    visit activity_path(as: @user)
  end

  describe "search by name" do
    describe "search for unclaimed user from board" do
      before(:each) do
        fill_in "autocomplete", with: "join"
      end

      it "should return user", js: true do
        autocomplete_status AUTOCOMPLETE_STATUS[:click]
        should_find_user @user0.name
        expect(found_users_count).to eq(1)
        should_have_invite_button @user0
      end

      context "invite unclaimed user" do
        before(:each) do
          page.find(".single_click_invite").click
        end

        skip "should send invitation", js: true, convert_to: "unit" do
          it "Another fucking unit test in an accpteance tests clothes"
          should_send_email @user0, @user, @demo1
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
        expect(found_users_count).to eq(1)
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
        expect(found_users_count).to eq(0)
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
        expect(found_users_count).to eq(1)
        should_have_invite_button @user0
      end

      context "invite unclaimed user" do
        before(:each) do
          page.find(".single_click_invite").click
        end

        it "should send invitation", js: true do
          should_send_email @user0, @user, @demo1
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
        expect(found_users_count).to eq(1)
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
        expect(found_users_count).to eq(1)
      end

      context "invite user" do
        before(:each) do
          page.find(".single_click_invite").click
          @potential_user = PotentialUser.last
        end

        it "should send invitation", js: true do
          should_send_email @user8, @user, @demo1
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
        expect(found_users_count).to eq(1)
      end

      scenario "invite user", js: true do
        page.find(".single_click_invite").click

        potential_user = PotentialUser.last
        should_send_email potential_user, @user, @demo1
      end
    end
  end


  def autocomplete_status status
    expect(page.find("#autocomplete_status")).to have_content status
  end

  def should_find_user name
    within ".single_suggestion" do
      expect(page).to have_content name
    end
  end

  def should_find_no_user name
    expect(page.all(".single_suggestion", text: name).count).to eq(0)
  end

  def found_users_count
    page.all(".single_suggestion").count
  end

  def should_have_invite_button user
    expect(page.find("#invitee_id[value='#{user.id}']", visible: false)).to be_present
  end

  def should_not_have_invite_button user
    expect(page.all("#invitee_id[value='#{user.id}']").count).to eq(0)
  end

  def should_send_email invitee, referrer, demo
    autocomplete_status AUTOCOMPLETE_STATUS[:sent]

    open_email invitee.email
    expect(current_email.to_s).to have_content "#{referrer.name} invited you to join #{demo.name}"
  end
end
