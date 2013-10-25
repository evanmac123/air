require 'acceptance/acceptance_helper'

feature 'there is a link to add new tile from activity page' do

  def add_tile_link
    page.all("a[href='#{new_client_admin_tile_path}']", text: "Add tile").first
  end

  def manage_tile_link
    page.all("a[href='#{client_admin_tiles_path}']", text: "Manage tiles").first
  end

  scenario 'visible to a client admin' do
    visit activity_path(as: a_client_admin)
    add_tile_link.should be_present
    manage_tile_link.should be_present
  end

  scenario 'invisible to a non-admin user' do
    visit activity_path(as: a_regular_user)
    add_tile_link.should be_nil
    manage_tile_link.should be_nil
  end
end
