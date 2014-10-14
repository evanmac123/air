require 'acceptance/acceptance_helper'

feature 'When conversion suppression is on' do
  before do
    @demo = FactoryGirl.create(:demo, is_public: true)
    $rollout.activate_user(:suppress_conversion_modal, @demo)
  end

  it "should display no conversion form on acts", js: true do
    visit acts_path(public_slug: @demo.public_slug)
    page.should have_no_css('#guest_conversion_form_wrapper', visible: true)
  end

  it "should show no connections section" do
    visit acts_path(public_slug: @demo.public_slug)
    expect_no_content "Connections"
  end

  it "should have no sign-in link in the welcome box", js: true do
    FactoryGirl.create(:multiple_choice_tile, :public, demo: @demo)
    visit acts_path(public_slug: @demo.public_slug)
    page.should have_css('#get_started_lightbox') # wait for the modal pop

    page.find('#get_started_lightbox').should have_no_content('Already a user? Sign in')
  end

  it "should have a different message for going outside the sandbox" do
    visit acts_path(public_slug: @demo.public_slug)
    visit users_path
    expect_no_content "Save your progress to access this part of the site."
    expect_content "Sorry, you don't have permission to access that part of the site." 
  end
end
