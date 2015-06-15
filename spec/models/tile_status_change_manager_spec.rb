require 'spec_helper'

describe TileStatusChangeManager do
	let(:user){FactoryGirl.create(:user)}
  let(:demo) { FactoryGirl.create :demo }
	describe "#process" do
		context "original status user_submitted" do
			let(:tile) { FactoryGirl.create :multiple_choice_tile, status: Tile::USER_SUBMITTED, demo: demo, original_creator: user }

			it "sends email if status is change to draft" do
				tile.status = Tile::DRAFT 
				mgr = TileStatusChangeManager.new(tile)
				mgr.expects(:send_acceptance_email)
				mgr.process
			end

			it "doesn't send email if status has not changed to draft" do
				tile.status = Tile::ACTIVE 
				mgr = TileStatusChangeManager.new(tile)
				mgr.expects(:send_acceptance_email).never
				mgr.process
			end
		end
		context "original status not user_submitted" do
			let(:tile) { FactoryGirl.create :multiple_choice_tile, status: Tile::USER_DRAFT, demo: demo, original_creator: user }

			it "it doesn't sends emails" do
				tile.status = Tile::DRAFT 
				mgr = TileStatusChangeManager.new(tile)
				mgr.expects(:send_acceptance_email).never
				mgr.process
			end

		end

  		context "has no original creator" do
			let(:tile) { FactoryGirl.create :multiple_choice_tile, status: Tile::USER_SUBMITTED, demo: demo, original_creator: nil }

			it "it doesn't sends emails" do
				tile.status = Tile::DRAFT 
				mgr = TileStatusChangeManager.new(tile)
				mgr.expects(:send_acceptance_email).never
				mgr.process
			end

		end

	end

end

