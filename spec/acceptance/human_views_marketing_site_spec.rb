require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Human views marketing site" do

  scenario "Human views marketing site", js: true do
    visit root_path
    # Product Tour
    page.should have_content("Connect employees to HR")
    click_link "Product tour"
    page.should have_content("Find the best path to each person")
    click_link "spark"
    page.should have_content("Generate excitement and motivate action")
    click_link "drive"
    page.should have_content("Measure effectiveness and maximize resources to be the best strategic partner")
    # Solutions
    click_link "Solutions"
    page.should have_content("Cut through the noise")
    page.find("#post").click
    page.should have_content("Build ongoing engagement")
    page.find("#play").click
    page.should have_content("data brought to life")
  end
end
