require 'acceptance/acceptance_helper'

feature 'Client admin segments on characteristics' do
  include WaitForAjax
  include SuggestionBox


  context "user is not site admin" do
    let!(:admin) { FactoryGirl.create :client_admin, is_site_admin: false}
    let!(:demo)  { admin.demo  }
    let!(:users) do
      users = (1..2).to_a.map do |num|
        FactoryGirl.create :user, demo: demo, name: "User#{num}"
      end
    end

    background do
      bypass_modal_overlays(admin)
      signin_as(admin, admin.password)
    end

    before do
      visit client_admin_tiles_path()
    end

    it "should show Suggestion Box Modal", js: true do
      expect_no_content "Manage Access"
    end
  end

  context "user is site admin" do
    let!(:admin) { FactoryGirl.create :client_admin, is_site_admin: true }
    let!(:demo)  { admin.demo  }
    let!(:users) do
      users = (1..4).to_a.map do |num|
        FactoryGirl.create :user, demo: demo, name: "User#{num}"
      end
    end

    background do
      bypass_modal_overlays(admin)
      signin_as(admin, admin.password)
    end

    before do
      FactoryGirl.create :tile, demo: demo
      visit client_admin_tiles_path()
      suggestion_box_title.click
    end

    it "should show Suggestion Box Modal", js: true do
      expect_no_content suggestion_box_header

      expect_content "Manage Access"
      manage_access_link.click

      expect_content suggestion_box_header
    end

    context "Suggestion Switcher" do
      before do
        manage_access_link.click
      end

      scenario "specific users should be checked by default without any users selected", js: true do
        within ".switcher" do
          expect(page).to have_css ".specific_users_copy.on"
          expect(page).to_not have_css ".all_users_copy.on"
        end
        user_rows.count.should == 0
      end

      it "should switch to all users", js: true do
        all_users_switcher_on.click
        expect_content "You've selected All Users in this Board to have access to Suggestion Box."
      end

      it "should save switcher state after clicking 'save'", js: true do
        within "#suggestions_access_modal" do
          all_users_switcher_on.click
          expect_content "You've selected All Users"
          demo.reload.everyone_can_make_tile_suggestions.should be_false

          save_button.click
          demo.reload.everyone_can_make_tile_suggestions.should be_true
          # save_and_open_page
        end
        
        manage_access_link.click
        within "#suggestions_access_modal" do
          specific_users_switcher_on.click
          expect_content "Type the name of an user"
          demo.reload.everyone_can_make_tile_suggestions.should be_true
        end
      end
    end

    context "Users Table" do
      before do
        manage_access_link.click
      end

      context "Autocomplete Input" do
        it "should autocomplete entered name and show users", js: true , driver: :webkit do
          fill_in_username_autocomplete("Use")
          autocomplete_result_names.count.should == 4
          autocomplete_result_names.should == ["User1", "User2", "User3", "User4"]

          fill_in_username_autocomplete("W")
          autocomplete_result_names.count.should == 1
          autocomplete_result_names[0] =~ /No match for W./
        end

        it "should add user from autocomplete list to user table on click", js: true , driver: :webkit do
          fill_in_username_autocomplete("Use")
          username_autocomplete_results_click 0

          wait_for_ajax
          user_rows.first.find(".user_name").text.should == "User1"

          save_button.click

          demo.users_that_allowed_to_suggest_tiles.pluck(:name).should == ["User1"]
        end
      end

      context "Removing" do
        before do
          users.first.update_allowed_to_make_tile_suggestions true, demo
          visit current_path
          suggestion_box_title.click
          manage_access_link.click
        end

        scenario "should remove user", js: true do
          id = users.first.id
          user_row = "tr.allowed_to_suggest_user[data-user-id='#{id}']"

          within  user_row do
            page.find(".user_remove a").click
          end
          save_button.click

          #automatically waits for ajax without the need for any WaitForAjax
          #This confirms that the modal was closed susccessfully
          expect(page).to_not have_content("Add people to suggestion box")

          manage_access_link.click #reopen modal
          within "table#allowed_to_suggest_users" do
            expect(page).to_not have_selector user_row
          end
        end
      end
    end

    context "Warning Modal" do
      before do
        users.first.update_allowed_to_make_tile_suggestions true, demo
        visit current_path
        suggestion_box_title.click
        manage_access_link.click
      end

      it "should confirm leaving if there is some unsaved changes", js: true do
        user_row = "tr.allowed_to_suggest_user[data-user-id='#{users.first.id}']"

        within  user_row do
          page.find(".user_remove a").click
        end

        user_rows.count.should == 0

        suggestion_box_cancel.click
        expect_content warning_modal_mess
        # cancel modal and this moves us back in suggestion box
        warning_cancel.click
        expect_content suggestion_box_header
        user_rows.count.should == 0

        suggestion_box_cancel.click
        expect_content warning_modal_mess
        # now confirm leaving
        warning_confirm.click
        expect_no_content suggestion_box_header
        # open box again and get our initial data
        manage_access_link.click
        expect_content suggestion_box_header
        user_rows.count.should == 1
      end
    end
  end
end
