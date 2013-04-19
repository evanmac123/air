require 'acceptance/acceptance_helper'

feature 'Adds location through user add form' do
  scenario "by choosing the magic value from the Location select", js: true do
    client_admin = FactoryGirl.create(:client_admin)
    visit client_admin_users_path(as: client_admin)

    demo = client_admin.demo
    demo.locations.length.should == 0

    # This is a bit of a hack to get around the fact that we can't actually
    # interact with the prompt window via Poltergeist.
    begin
      page.evaluate_script "window.original_prompt_function = window.prompt"
      page.evaluate_script "window.prompt = function(msg) { return 'Funkytown' }"

      select "Add new...", from: "Location"

    ensure
      page.evaluate_script "window.prompt = window.original_prompt_function"
    end

    fill_in "Name", with: "Mayor McCheese"
    click_button "Add user"

    demo.users.length.should == 2 # new guy + existing admin
    demo.reload.locations.length.should == 1
    demo.users.find_by_name("Mayor McCheese").location.name.should == "Funkytown"
  end
end
