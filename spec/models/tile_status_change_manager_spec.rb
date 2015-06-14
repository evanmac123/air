require 'spec_helper'

describe TileStatusChangeManager do
	let(:user){FactoryGirl.create(:user)}
  let(:demo) { FactoryGirl.create :demo }
	let(:tile) { FactoryGirl.create :multiple_choice_tile, status: Tile::USER_SUBMITTED, demo: demo, original_creator: user }

	describe "#process" do
		it "sends email if status is draft" do
			tile.status = Tile::DRAFT 
			mgr = TileStatusChangeManager.new(tile)
			mgr.expects(:send_acceptance_email)
			mgr.process
		end

		it "sends email if status is draft" do
			tile.status = Tile::ACTIVE 
			mgr = TileStatusChangeManager.new(tile)
			mgr.expects(:send_acceptance_email).never
			mgr.process
		end
	end

end

