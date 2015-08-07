require 'acceptance/acceptance_helper'

feature 'Mime types on image uploads validated' do
  def expect_no_file_attachment_set
    page.find('#upload_preview')['src'].should == "/assets/avatars/thumb/missing.png"
  end

  pending "in tile upload", js: true do
    visit new_client_admin_tile_path(as: a_client_admin)
    fake_upload_image "not_an_image.txt"
  end
end
