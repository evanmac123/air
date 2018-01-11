require 'acceptance/acceptance_helper'

feature 'Invites user' do
  context "from the edit page" do
    before do
      @user = FactoryBot.create(:user)
      @client_admin = FactoryBot.create(:client_admin, demo: @user.demo)
      expect(@user).not_to be_invited
    end

    context "when the user has an email address" do
      it "should work and have feedback" do
        visit edit_client_admin_user_path(@user, as: @client_admin)
        click_link "Send invite"

        should_be_on edit_client_admin_user_path(@user)
        expect(@user.reload).to be_invited
        expect_content "OK, we've just sent #{@user.name} an invitation."
      end
    end

    context "when the user doesn't have an email address" do
      before do
        @user.update_attributes(email: "")
      end

      it "shouldn't be an option" do
        visit edit_client_admin_user_path(@user, as: @client_admin)
        expect_no_content "Send an invite"
      end
    end
  end

  context "from the add page after creating a user" do
    before do
      client_admin = FactoryBot.create(:client_admin)
      @demo = client_admin.demo
      FactoryBot.create :tile, demo: @demo
      visit client_admin_users_path(as: client_admin)
      fill_in "user[name]", with: "Bob Jones"
    end

    it "should have a link in the add message to invite the newly-created user, if they have an email", js: true do
      fill_in "user[email]", with: "bob@acme.co.uk"
      click_button "Add User"

      new_user = @demo.users.order("created_at DESC").first
      expect(new_user.invited).to be_falsey
      click_link "Next, send invite to Bob Jones"

      expect(new_user.reload.invited).to be_truthy
      expect_content "Success!"
      expect_no_content "Next, send invite to Bob Jones"
    end
  end
end
