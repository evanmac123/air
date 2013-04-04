require 'acceptance/acceptance_helper'

feature 'Uses alternate demo request form' do
  def click_alternate_demo_link
    page.all('a.request_a_demo').first.click
  end

  def fill_in_all_fields
    page.find("#contact_name").set "Josef Banan"
    page.find("#contact_email").set "josef@kgb.ru"
    page.find("#contact_phone").set "415-555-1212"
    page.find("#contact_comment").set "Awesome!"
  end

  def click_submit_button
    page.find("#request_demo form input[type=submit]").click
  end

  before do
    pending "This works, but our JS testing situation is at the corner of Bullshit and Oh My God Do You Believe This Bullshit."
  end

  it "should notify the Ks", js: :webkit do
    visit root_path

    click_alternate_demo_link

    fill_in_all_fields
    click_submit_button

    pending
  end

  it "should show a cheerful message when submitting", js: :webkit do
    pending
  end

  it "should keep the submit button disabled until all necessary information is present", js: :webkit do
    pending
  end
end
