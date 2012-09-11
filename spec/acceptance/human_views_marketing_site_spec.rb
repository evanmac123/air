require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Human views marketing site" do

  scenario "Human views marketing site", js: true do
    visit root_path
    # Product Tour
    page.should have_content("Increase engagement in HR")
    click_link "Product tour"
    page.should have_content("Find the best path to each person")
    click_link "spark"
    page.should have_content("Generate excitement and motivate action")
    click_link "drive"
    page.should have_content("Measure effectiveness and maximize resources to be the best strategic partner")
    # Solutions
    click_link "Solutions"
    page.should have_content("Send messages to employees in their preferred communication channels")
    page.find("#post").click
    page.should have_content("Build sustained engagement")
    page.find("#play").click
    page.should have_content("Transform messages and behaviors into a social, mobile game.")
  end
end
