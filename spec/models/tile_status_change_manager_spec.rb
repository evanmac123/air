require 'spec_helper'

describe TileStatusChangeManager do
	let(:user){FactoryGirl.create(:user)}
	let(:demo) { FactoryGirl.create :demo }
	describe "#process" do

		context "user_submitted" do
			#use 'Factory.build'  to avoid weird behaviors caused by callback implentation
			it "doesn't send admin email if not a new record" do
				tile = FactoryGirl.build :multiple_choice_tile, status: Tile::USER_SUBMITTED,  demo: demo, creator: user, user_created: true 
				tile.stubs(:new_record?).returns(false)
				do_no_admin_email_sent tile
			end

			it "sends admin email if new record and status is USER_SUBMITTED" do
				tile = FactoryGirl.build :multiple_choice_tile, status: Tile::USER_SUBMITTED,  demo: demo, creator: user, user_created: true 
				do_user_submitted tile
			end

			it "doesn't sends emails status not user_submitted" do
				tile = FactoryGirl.build :multiple_choice_tile,  status: Tile::DRAFT, demo: demo, creator: user, user_created: true  
				do_no_admin_email_sent tile
			end

			it "doesn't sends emails if user_created is nil" do
				tile = FactoryGirl.build :multiple_choice_tile, status: Tile::USER_SUBMITTED, demo: demo, creator: user, user_created: nil  
				do_no_admin_email_sent tile
			end

			it "doesn't sends emails if user_created is false" do
				tile = FactoryGirl.build :multiple_choice_tile, status: Tile::USER_SUBMITTED, demo: demo, creator: user, user_created: false  
				tile.user_created =  false
				do_no_admin_email_sent tile
			end

			it "doesn't sends emails if it has no creator" do
				tile = FactoryGirl.build :multiple_choice_tile, status: Tile::USER_SUBMITTED, demo: demo, creator: nil, user_created: true  
				do_no_admin_email_sent tile
			end
		end

		context "accepted" do
			context "original status USER_SUBMITTED" do
				let(:tile) { FactoryGirl.create :multiple_choice_tile, status: Tile::USER_SUBMITTED, demo: demo, creator: user, user_created: true }

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


			it "doesn't sends emails original status not USER_SUBMITTED" do
				tile = FactoryGirl.create :multiple_choice_tile, status: Tile::USER_DRAFT, demo: demo, creator: user, user_created: true
				tile.status = Tile::DRAFT 
				mgr = TileStatusChangeManager.new(tile)
				mgr.expects(:send_acceptance_email).never
				mgr.process
			end

			context "is not user created" do
				let(:tile) { FactoryGirl.create :multiple_choice_tile, status: Tile::USER_DRAFT, demo: demo, creator: user, user_created: nil  }
				it "doesn't sends emails if user_created is nil" do
					tile.status = Tile::DRAFT 
					mgr = TileStatusChangeManager.new(tile)
					mgr.expects(:send_acceptance_email).never
					mgr.process
				end

				it "doesn't sends emails if user_created is false" do
					tile.user_created =  false
					tile.status = Tile::DRAFT 
					mgr = TileStatusChangeManager.new(tile)
					mgr.expects(:send_acceptance_email).never
					mgr.process
				end
			end

			it "doesn't sends emails if it has no creator" do
				tile = FactoryGirl.create :multiple_choice_tile, status: Tile::USER_SUBMITTED, demo: demo, creator: nil, user_created: true
				tile.status = Tile::DRAFT 
				mgr = TileStatusChangeManager.new(tile)
				mgr.expects(:send_acceptance_email).never
				mgr.process
			end
		end

		context "posted" do

			context "original status DRAFT" do
				let(:tile) { FactoryGirl.create :multiple_choice_tile, status: Tile::DRAFT, demo: demo, creator: user, user_created: true }

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


				it "doesn't sends emails original status not DRAFT" do
				tile = FactoryGirl.create :multiple_choice_tile, status: Tile::USER_SUBMITTED, demo: demo, creator: user, user_created: true
					tile.status = Tile::ACTIVE 
					mgr = TileStatusChangeManager.new(tile)
					mgr.expects(:send_posted_email).never
					mgr.process
				end



				it "doesn't sends emails if has no creator" do
					tile = FactoryGirl.create :multiple_choice_tile, status: Tile::DRAFT, demo: demo, creator: nil, user_created: true  
					tile.status = Tile::ACTIVE 
					mgr = TileStatusChangeManager.new(tile)
					mgr.expects(:send_posted_email).never
					mgr.process
				end

		end
	end
	context "archived" do

		context "original status ARCHIVE" do
			let(:tile) { FactoryGirl.create :multiple_choice_tile, status: Tile::ACTIVE, demo: demo, creator: user, user_created: true }

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

		it "doesn't sends emails if original status not ACTIVE" do
			tile = FactoryGirl.create :multiple_choice_tile, status: Tile::DRAFT, demo: demo, creator: user, user_created: true
			tile.status = Tile::ARCHIVE 
			mgr = TileStatusChangeManager.new(tile)
			mgr.expects(:send_archived_email).never
			mgr.process
		end

		it "doesn't sends emails if it has no  creator" do
			tile = FactoryGirl.create :multiple_choice_tile, status: Tile::ACTIVE, demo: demo, creator: nil, user_created: true
			tile.status = Tile::ARCHIVE 
			mgr = TileStatusChangeManager.new(tile)
			mgr.expects(:send_archived_email).never
			mgr.process
		end
	end


	def do_user_submitted tile
		mgr = TileStatusChangeManager.new(tile)
		mgr.expects(:send_submitted_email)
		mgr.process
	end

	def do_no_admin_email_sent tile
		mgr = TileStatusChangeManager.new(tile)
		mgr.expects(:send_submitted_email).never
		mgr.process
	end

end
