require 'spec_helper'

describe SuggestedTileStatusChangeManager do
  let(:user){FactoryBot.create(:user)}
  let(:demo) { FactoryBot.create :demo }
  describe "#process" do

    context "user_submitted" do
      #use 'Factory.build'  to avoid weird behaviors caused by callback implentation
      it "sends admin email if new record and status is USER_SUBMITTED" do
        tile = FactoryBot.create :tile, status: Tile::USER_SUBMITTED,  demo: demo, creator: user, creation_source_cd: Tile.creation_sources[:suggestion_box_created]
        do_user_submitted tile
      end

      it "doesn't sends emails status not user_submitted" do
        tile = FactoryBot.create :tile,  status: Tile::DRAFT, demo: demo, creator: user, creation_source_cd: Tile.creation_sources[:suggestion_box_created]
        do_no_admin_email_sent tile
      end

      it "doesn't sends emails if user_created is nil" do
        tile = FactoryBot.create :tile, status: Tile::USER_SUBMITTED, demo: demo, creator: user, creation_source_cd: Tile.creation_sources[:client_admin_created]
        do_no_admin_email_sent tile
      end

      it "doesn't sends emails if user_created is false" do
        tile = FactoryBot.create :tile, status: Tile::USER_SUBMITTED, demo: demo, creator: user, creation_source_cd: Tile.creation_sources[:client_admin_created]
        tile.user_created =  false
        do_no_admin_email_sent tile
      end

      it "doesn't sends emails if it has no creator" do
        tile = FactoryBot.create :tile, status: Tile::USER_SUBMITTED, demo: demo, creator: nil, creation_source_cd: Tile.creation_sources[:suggestion_box_created]
        do_no_admin_email_sent tile
      end
    end

    context "accepted" do
      context "original status USER_SUBMITTED" do
        let(:tile) { FactoryBot.create :tile, status: Tile::USER_SUBMITTED, demo: demo, creator: user, creation_source_cd: Tile.creation_sources[:suggestion_box_created] }

        it "sends email if status is changed to DRAFT" do
          tile.status = Tile::DRAFT
          tile.save
          mgr = SuggestedTileStatusChangeManager.new(tile)
          mgr.expects(:send_acceptance_email)
          mgr.process
        end

        it "doesn't send email if status has not changed to DRAFT" do
          tile.status = Tile::ACTIVE
          tile.save
          mgr = SuggestedTileStatusChangeManager.new(tile)
          mgr.expects(:send_acceptance_email).never
          mgr.process
        end
      end


      it "doesn't sends emails original status not USER_SUBMITTED" do
        tile = FactoryBot.create :tile, status: Tile::USER_DRAFT, demo: demo, creator: user, creation_source_cd: Tile.creation_sources[:suggestion_box_created]
        tile.status = Tile::DRAFT
        tile.save
        mgr = SuggestedTileStatusChangeManager.new(tile)
        mgr.expects(:send_acceptance_email).never
        mgr.process
      end

      context "is not user created" do
        let(:tile) { FactoryBot.create :tile, status: Tile::USER_DRAFT, demo: demo, creator: user, creation_source_cd: Tile.creation_sources[:client_admin_created]  }
        it "doesn't sends emails if user_created is nil" do
          tile.status = Tile::DRAFT
          tile.save
          mgr = SuggestedTileStatusChangeManager.new(tile)
          mgr.expects(:send_acceptance_email).never
          mgr.process
        end

        it "doesn't sends emails if user_created is false" do
          tile.user_created =  false
          tile.status = Tile::DRAFT
          tile.save
          mgr = SuggestedTileStatusChangeManager.new(tile)
          mgr.expects(:send_acceptance_email).never
          mgr.process
        end
      end

      it "doesn't sends emails if it has no creator" do
        tile = FactoryBot.create :tile, status: Tile::USER_SUBMITTED, demo: demo, creator: nil, creation_source_cd: Tile.creation_sources[:suggestion_box_created]
        tile.status = Tile::DRAFT
        tile.save
        mgr = SuggestedTileStatusChangeManager.new(tile)
        mgr.expects(:send_acceptance_email).never
        mgr.process
      end
    end

    context "posted" do

      context "original status DRAFT" do
        let(:tile) { FactoryBot.create :tile, status: Tile::DRAFT, demo: demo, creator: user, creation_source_cd: Tile.creation_sources[:suggestion_box_created] }

        it "sends email if status is change to ACTIVE" do
          tile.status = Tile::ACTIVE
          tile.save
          mgr = SuggestedTileStatusChangeManager.new(tile)
          mgr.expects(:send_posted_email)
          mgr.process
        end

        it "doesn't send email if status has not changed to ACTIVE" do
          tile.status = Tile::IGNORED
          tile.save
          mgr = SuggestedTileStatusChangeManager.new(tile)
          mgr.expects(:send_posted_email).never
          mgr.process
        end
      end


      it "doesn't sends emails original status not DRAFT" do
        tile = FactoryBot.create :tile, status: Tile::USER_SUBMITTED, demo: demo, creator: user, creation_source_cd: Tile.creation_sources[:suggestion_box_created]
        tile.status = Tile::ACTIVE
        tile.save
        mgr = SuggestedTileStatusChangeManager.new(tile)
        mgr.expects(:send_posted_email).never
        mgr.process
      end



      it "doesn't sends emails if has no creator" do
        tile = FactoryBot.create :tile, status: Tile::DRAFT, demo: demo, creator: nil, creation_source_cd: Tile.creation_sources[:suggestion_box_created]
        tile.status = Tile::ACTIVE
        tile.save
        mgr = SuggestedTileStatusChangeManager.new(tile)
        mgr.expects(:send_posted_email).never
        mgr.process
      end

    end
  end

  def do_user_submitted tile
    mgr = SuggestedTileStatusChangeManager.new(tile)
    mgr.expects(:send_submitted_email)
    mgr.process
  end

  def do_no_admin_email_sent tile
    mgr = SuggestedTileStatusChangeManager.new(tile)
    mgr.expects(:send_submitted_email).never
    mgr.process
  end

end
