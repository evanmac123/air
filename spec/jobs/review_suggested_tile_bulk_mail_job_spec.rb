require 'rails_helper'

RSpec.describe ReviewSuggestedTileBulkMailJob, type: :job do
  describe ".perform" do
    let!(:demo) {FactoryBot.create :demo, email: "demo@gmail.com"}

    before do
      john   = FactoryBot.create :client_admin, demo: demo, name: 'CA John',   email: 'john@beatles.com'
      paul   = FactoryBot.create :client_admin, demo: demo, name: 'CA Paul',   email: 'paul@beatles.com'
      george = FactoryBot.create :client_admin, demo: demo, name: 'CA George', email: 'george@beatles.com'

      @admins = [john, paul, george]
      @tile_sender =  FactoryBot.create :user, demo: demo, email: "user@airbo.com", name: "Tile Sender"
      @tile = FactoryBot.create(:tile, creation_source_cd: Tile.creation_sources[:suggestion_box_created], creator: @tile_sender, demo: demo)

      update_board_memberships
    end

    it 'should be delivered only to client admins of selected demo' do
      mock_delivery = ActionMailer::Base::NullMail.new

      @admins.each do |ca|
        SuggestedTileReviewMailer.expects(:notify_one).with(ca.id, demo.id, @tile_sender.name, @tile_sender.email).returns(mock_delivery)
      end

      ReviewSuggestedTileBulkMailJob.perform_later(tile: @tile)
   end
  end

  def update_board_memberships
    BoardMembership.all.each do |bm|
      bm.is_client_admin = bm.user.is_client_admin
      bm.save
    end
  end
end
