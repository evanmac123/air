require 'acceptance/acceptance_helper'

feature 'Client admin segments on characteristics' do
  include WaitForAjax

  let!(:admin) { FactoryGirl.create :client_admin }
  let!(:demo)  { admin.demo  }
  let!(:users) do 
    users = (1..4).to_a.map do |num|
      FactoryGirl.create :user, demo: demo, name: "User#{num}"
    end
  end

  def manage_access_link
    page.find(".manage_access")
  end

  def all_users_switcher_on
    page.find("#suggestion_switcher_on")
  end

  def specific_users_switcher_on
    page.find("#suggestion_switcher_off")
  end

  def user_rows
    page.all(".allowed_to_suggest_user")
  end

  def save_button
    page.find("#save_suggestion_box")
  end

  def autocomplete_input
    page.find("#name_substring")
  end

  def fill_in_username_autocomplete(name)
    autocomplete_input.set(name)
    page.execute_script("$('#name_substring').autocomplete('search')")
    wait_for_ajax
  end

  def username_autocomplete_results_click num
    selector = "#name_autocomplete_target li a:first"
    page.execute_script %Q{ $('#{selector}').eq(#{num}).trigger('mouseenter').click() }
  end

  def autocomplete_result_names
    page.all("#name_autocomplete_target li a").map(&:text)
  end

  def warning_modal_mess
    "Are you sure you want to close this form? You haven't saved changes."
  end

  def suggestion_box_header
    "Add people to suggestion box"
  end

  def suggestion_box_cancel
    page.find("#cancel_suggestion_box")
  end

  def warning_cancel
    page.find("#suggestion_box_warning_modal .cancel")
  end

  def warning_confirm
    page.find("#suggestion_box_warning_modal .confirm")
  end

  background do
    bypass_modal_overlays(admin)
    signin_as(admin, admin.password)
  end

  before do
    visit client_admin_tiles_path
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
      specific_users_switcher_on.should be_checked
      all_users_switcher_on.should_not be_checked

      user_rows.count.should == 0
    end

    it "should switch to all users", js: true do
      all_users_switcher_on.click
      expect_content "You've selected All Users in this Board to have access to Suggestion Box."
    end

    it "should save switcher state after clicking 'save'", js: true do
      all_users_switcher_on.click
      demo.reload.everyone_can_make_tile_suggestions.should be_false

      save_button.click
      demo.reload.everyone_can_make_tile_suggestions.should be_true

      specific_users_switcher_on.click
      demo.reload.everyone_can_make_tile_suggestions.should be_true

      save_button.click
      demo.reload.everyone_can_make_tile_suggestions.should be_false
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
        manage_access_link.click
      end

      it "should remove user", js: true do
        demo.users_that_allowed_to_suggest_tiles.pluck(:name).should == ["User1"]

        user_rows[0].find(".user_remove a").click
        user_rows.count.should == 0

        save_button.click
        demo.users_that_allowed_to_suggest_tiles.count.should == 0
      end
    end
  end

  context "Warning Modal" do
    before do
      users.first.update_allowed_to_make_tile_suggestions true, demo
      visit current_path 
      manage_access_link.click
    end

    it "should confirm leaving if there is some unsaved changes", js: true do
      user_rows[0].find(".user_remove a").click
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