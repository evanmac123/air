require 'acceptance/acceptance_helper'

feature 'Client admin segments on characteristics', js: true do
  include SuggestionBox

  context "user is not site admin" do
    let!(:admin) { FactoryBot.create :client_admin, is_site_admin: false}
    let!(:demo)  { admin.demo  }
    let!(:users) do
      (1..2).to_a.map do |num|
        FactoryBot.create :user, demo: demo, name: "User#{num}"
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
    let!(:admin) { FactoryBot.create :client_admin, is_site_admin: true }
    let!(:demo)  { admin.demo  }
    let!(:users) do
      (1..4).to_a.map do |num|
        FactoryBot.create :user, demo: demo, name: "User#{num}"
      end
    end

    background do
      bypass_modal_overlays(admin)
      signin_as(admin, admin.password)
    end

    before do
      FactoryBot.create :tile, demo: demo
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
        expect(user_rows.count).to eq(0)
      end

      it "should switch to all users", js: true do
        all_users_switcher_on.click
        expect_content "You've selected All Users in this Board to have access to Suggestion Box."
      end
    end

    context "Users Table" do
      before do
        manage_access_link.click
      end

      context "Autocomplete Input" do
        it "should autocomplete entered name and show users", js: true do
          fill_in_username_autocomplete("Use")
          #expect(autocomplete_result_names.count).to eq(4)
          #expect(autocomplete_result_names).to eq(["User1", "User2", "User3", "User4"])

          fill_in_username_autocomplete("W")
          expect(autocomplete_result_names.count).to eq(1)
          autocomplete_result_names[0] =~ /No match for W./
        end

        it "should add user from autocomplete list to user table on click", js: true do
          fill_in_username_autocomplete("Use")
          username_autocomplete_results_click 0

          expect(user_rows.first.find(".user_name").text).to eq("User1")

          save_button.click

          expect(demo.users_that_allowed_to_suggest_tiles.pluck(:name)).to eq(["User1"])
        end
      end

      context "Removing" do
        before do
          bm = users.first.board_memberships.where(demo: demo).first
          bm.update_attribute(:allowed_to_make_tile_suggestions, true)
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
        bm = users.first.board_memberships.where(demo: demo).first
        bm.update_attribute(:allowed_to_make_tile_suggestions, true)
        visit current_path
        suggestion_box_title.click
        manage_access_link.click
      end

      it "should confirm leaving if there is some unsaved changes", js: true do
        user_row = "tr.allowed_to_suggest_user[data-user-id='#{users.first.id}']"

        within  user_row do
          page.find(".user_remove a").click
        end

        expect(user_rows.count).to eq(0)

        suggestion_box_cancel.click
        expect_content warning_modal_mess
        # cancel modal and this moves us back in suggestion box
        warning_cancel.click
        expect_content suggestion_box_header
        expect(user_rows.count).to eq(0)

        suggestion_box_cancel.click
        expect_content warning_modal_mess
        # now confirm leaving
        warning_confirm.click
        expect_no_content suggestion_box_header
        # open box again and get our initial data
        manage_access_link.click
        expect_content suggestion_box_header
        expect(user_rows.count).to eq(1)
      end
    end
  end
end
