require 'spec_helper'

describe TileStatusChangeManager do
	let(:user){FactoryGirl.create(:user)}
	let(:demo) { FactoryGirl.create :demo }
	describe "#process" do

		context "original status USER_SUBMITTED" do
			let(:tile) { FactoryGirl.create :multiple_choice_tile, status: Tile::USER_SUBMITTED, demo: demo, original_creator: user }

			it "sends email if status is change to DRAFT" do
				tile.status = Tile::DRAFT 
				mgr = TileStatusChangeManager.new(tile)
				mgr.expects(:send_acceptance_email)
				mgr.process
			end

			it "doesn't send email if status has not changed to DRAFT" do
				tile.status = Tile::ACTIVE 
				mgr = TileStatusChangeManager.new(tile)
				mgr.expects(:send_acceptance_email).never
				mgr.process
			end
		end

		context "original status not USER_SUBMITTED" do
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


	describe "#posted" do

		context "original status DRAFT" do
			let(:tile) { FactoryGirl.create :multiple_choice_tile, status: Tile::DRAFT, demo: demo, original_creator: user }

			it "sends email if status is change to ACTIVE" do
				tile.status = Tile::ACTIVE 
				mgr = TileStatusChangeManager.new(tile)
				mgr.expects(:send_posted_email)
				mgr.process
			end

			it "doesn't send email if status has not changed to ACTIVE" do
				tile.status = Tile::IGNORED 
				mgr = TileStatusChangeManager.new(tile)
				mgr.expects(:send_posted_email).never
				mgr.process
			end
		end

		context "original status not <DRAF></DRAF>T" do
			let(:tile) { FactoryGirl.create :multiple_choice_tile, status: Tile::USER_SUBMITTED, demo: demo, original_creator: user }

			it "it doesn't sends emails" do
				tile.status = Tile::ACTIVE 
				mgr = TileStatusChangeManager.new(tile)
				mgr.expects(:send_posted_email).never
				mgr.process
			end

		end

		context "has no original creator" do
			let(:tile) { FactoryGirl.create :multiple_choice_tile, status: Tile::DRAFT, demo: demo, original_creator: nil }

			it "it doesn't sends emails" do
				tile.status = Tile::ACTIVE 
				mgr = TileStatusChangeManager.new(tile)
				mgr.expects(:send_posted_email).never
				mgr.process
			end
		end

	end

	describe "#archived" do

		context "original status ARCHIVE" do
			let(:tile) { FactoryGirl.create :multiple_choice_tile, status: Tile::ACTIVE, demo: demo, original_creator: user }

			it "sends email if status is change to ARCHIVE" do
				tile.status = Tile::ARCHIVE 
				mgr = TileStatusChangeManager.new(tile)
				mgr.expects(:send_archived_email)
				mgr.process
			end

			it "doesn't send email if status has not changed to ARCHIVE" do
				tile.status = Tile::IGNORED 
				mgr = TileStatusChangeManager.new(tile)
				mgr.expects(:send_archived_email).never
				mgr.process
			end

		end

		context "original status not ACTIVE" do
			let(:tile) { FactoryGirl.create :multiple_choice_tile, status: Tile::DRAFT, demo: demo, original_creator: user }

			it "it doesn't sends emails" do
				tile.status = Tile::ARCHIVE 
				mgr = TileStatusChangeManager.new(tile)
				mgr.expects(:send_archived_email).never
				mgr.process
			end

		end

		context "has no original creator" do
			let(:tile) { FactoryGirl.create :multiple_choice_tile, status: Tile::ACTIVE, demo: demo, original_creator: nil }

			it "it doesn't sends emails" do
				tile.status = Tile::ARCHIVE 
				mgr = TileStatusChangeManager.new(tile)
				mgr.expects(:send_archived_email).never
				mgr.process
			end
		end
	end

end
