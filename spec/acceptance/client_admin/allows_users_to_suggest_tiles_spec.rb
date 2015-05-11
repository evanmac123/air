require 'acceptance/acceptance_helper'

feature 'Client admin segments on characteristics' do
  include WaitForAjax

  let!(:admin) { FactoryGirl.create :client_admin }
  let!(:demo)  { admin.demo  }
  let!(:users) do 
    (1..4).to_a.map do |num|
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
    page.execute_script("$('#name_substring').focus().keydown().keyup()")
    #fill_in "name_substring", with: name
    wait_for_ajax
  end

  def username_autocomplete_results
    p page.all("#name_autocomplete_target li")
    page.all("#name_autocomplete_target li a").map(&:text)
  end

  background do
    bypass_modal_overlays(admin)
    signin_as(admin, admin.password)
  end

  before do
    visit client_admin_tiles_path
  end

  it "should show Suggestion Box Modal", js: true do
    expect_no_content "Add people to suggestion box"

    expect_content "Manage Access"
    manage_access_link.click

    expect_content "Add people to suggestion box"
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
      it "should autocomplete entered name and show users", js: true do#, driver: :selenium do
        fill_in_username_autocomplete("Use")
        #sleep 100
        username_autocomplete_results.count.should == 4
        username_autocomplete_results.should == ["User1", "User2", "User3", "User4"]

        fill_in_username_autocomplete("W")
        username_autocomplete_results.count.should == 1
        username_autocomplete_results[0] =~ "No match for W."
      end

      #it "should add user from autocomplete list to user table on click"
    end
  end
end