require 'acceptance/acceptance_helper'

feature 'Client admin automates tile email', js: true do
  let!(:demo)  { FactoryBot.create :demo, email: 'foobar@playhengage.com' }
  let!(:admin) { FactoryBot.create :client_admin, email: 'client-admin@hengage.com', demo: demo, phone_number: "+3333333333" }

  before do
    admin.board_memberships.update_all(created_at: Time.current)
    user = FactoryBot.create :user, demo: demo
    tile = create_tile on_day: '7/5/2013', activated_on: '7/5/2013', status: Tile::DRAFT, demo: demo, headline: "Tile completed"
    FactoryBot.create(:tile_completion, tile: tile, user: user)
  end

  context 'No tiles exist for digest email' do
    before do
      visit client_admin_share_path(as: admin)
      click_on 'Automate'
    end

    it 'automation text is correct' do
      expect_content 'No Tiles have been delivered'
    end
  end

  context 'Tiles exist for digest email' do
    before do
      create_tile
      visit client_admin_share_path(as: admin)
      click_on 'Automate'
      click_on 'Schedule Tiles Digests'
    end

    it 'creates digest by clicking CTA' do
      expect(admin.demo.tiles_digest_automator).to exist
    end
  end

  # context 'without tiles in demo' do
  #   context 'digest email' do
  #     before do
  #       visit email_client_admin_tiles_digest_preview_path(as: client_admin)
  #     end
  #
  #     it 'should show empty digest email' do
  #       expect_content 'Your New Tiles Are Here!'
  #       expect_content 'No tiles posted'
  #     end
  #   end
  #
  #   context 'follow up email' do
  #     before do
  #       visit email_client_admin_tiles_digest_preview_path(follow_up_email: true, as: client_admin)
  #     end
  #
  #     it 'should show empty follow up email' do
  #       expect_content "Don't miss your new tiles"
  #       expect_content 'No tiles posted'
  #     end
  #   end
  # end
end
