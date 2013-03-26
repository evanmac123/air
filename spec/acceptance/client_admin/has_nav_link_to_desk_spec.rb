require 'acceptance/acceptance_helper'

feature 'Has nav link to desk' do
  scenario 'with the correct URL' do
    fake_url = "https://www.example.com/hengage-desk"
    DeskSSO.any_instance.stubs(:url).returns(fake_url)

    visit(client_admin_path(as: a_client_admin))
    
    desk_link = page.find("a[href='#{fake_url}']")
    desk_link.text.should == "Help pages"
  end
end
