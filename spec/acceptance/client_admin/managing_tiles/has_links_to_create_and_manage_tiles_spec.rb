require 'acceptance/acceptance_helper'

feature 'there is a link to manage tiles from activity page' do
  def manage_tile_link
    page.all("a[href='#{client_admin_tiles_path}']", text: "Manage").first
  end

  scenario 'visible to a client admin' do
    visit activity_path(as: a_client_admin)
    expect(manage_tile_link).to be_present
  end

  scenario 'invisible to a non-admin user' do
    visit activity_path(as: a_regular_user)
    expect(manage_tile_link).to be_nil
  end
end
