require 'acceptance/acceptance_helper'

feature 'Has nav link to desk' do
  let(:fake_url)            { "https://www.example.com/hengage-desk" }
  let(:desk_link_selector)  { "a[href='#{fake_url}']" }
  let(:desk_link_text)      { "Help pages" }

  before do
    DeskSSO.any_instance.stubs(:url).returns(fake_url)
  end

  # Until we get a bit of content up there, this is restricted to site admins
  # only.

  scenario 'with the correct URL' do
    visit(client_admin_path(as: a_client_admin))
    
    desk_link = page.find(desk_link_selector)
    desk_link.text.should == desk_link_text
  end
end
