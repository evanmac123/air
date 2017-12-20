require 'spec_helper'

def new_tile_email_report(tile_email)
  Reports::TileEmailReport.new(tile_email: tile_email)
end

describe Reports::TileEmailReport do
  describe "#attributes" do
    let(:client_admin) { FactoryBot.create(:client_admin) }
    let(:demo) { client_admin.demo }

    let(:tile_email) {
      demo.tiles_digests.create(
        sender_id: client_admin.id,
        subject: "Subject A",
        alt_subject: "Subject B",
        recipient_count: 200,
        delivered: true
      )
    }

    it "returns the correct type" do
      report = new_tile_email_report(tile_email)
      attributes = report.attributes

      expect(attributes[:type]).to eq("Reports::TileEmailReport")
    end

    it "returns the correct tile email id" do
      report = new_tile_email_report(tile_email)
      attributes = report.attributes

      expect(attributes[:tileEmailId]).to eq(tile_email.id)
    end

    it "returns the tile email sent at in utc" do
      report = new_tile_email_report(tile_email)
      attributes = report.attributes

      expect(attributes[:tileEmailSentAt]).to eq(tile_email.created_at.utc)
    end

    it "returns the correct sender" do
      report = new_tile_email_report(tile_email)
      attributes = report.attributes

      expect(attributes[:sender]).to eq(client_admin.name)
    end

    it "returns the correct tiles count" do
      tiles = FactoryBot.create_list(:tile, 5, demo: demo)
      tile_email.tiles << tiles

      report = new_tile_email_report(tile_email)
      attributes = report.attributes

      expect(attributes[:tilesCount]).to eq(5)
    end

    it "returns the correct recipient count" do
      report = new_tile_email_report(tile_email)
      attributes = report.attributes

      expect(attributes[:recipientCount]).to eq(200)
    end

    describe "#follow_up_status" do
      it "returns scheduled status when follow up is scheduled" do
        tile_email.create_follow_up_digest_email

        report = new_tile_email_report(tile_email)
        attributes = report.attributes

        expect(attributes[:followUpStatus]).to eq(Reports::TileEmailReport::FOLLOW_UP_SCHEDULED_STATUS)
      end

      it "returns delivered status when follow up is delivered" do
        tile_email.create_follow_up_digest_email
        tile_email.update_attributes(followup_delivered: true)

        report = new_tile_email_report(tile_email)
        attributes = report.attributes

        expect(attributes[:followUpStatus]).to eq(Reports::TileEmailReport::FOLLOW_UP_DELIVERED_STATUS)
      end

      it "returns no follow up status if there is no follow up" do
        report = new_tile_email_report(tile_email)
        attributes = report.attributes

        expect(attributes[:followUpStatus]).to eq(Reports::TileEmailReport::NO_FOLLOW_UP_STATUS)
      end
    end

    it "returns the correct tile attributes" do
      tile = FactoryBot.create(:tile, demo: demo)
      tile_email.tiles << tile

      report = new_tile_email_report(tile_email)
      attributes = report.attributes

      expect(attributes[:tiles]).to eq([
        {
          id: tile.id,
          image_url: tile.thumbnail.url,
          headline: tile.headline,
          views: tile.total_views,
          completions: tile.interactions
        }
      ])
    end

    describe "#subject_lines_with_login_count" do
      describe "when there are no logins" do
        it "returns a hash with subjects and no logins" do
          report = new_tile_email_report(tile_email)
          attributes = report.attributes

          expect(attributes[:loginsBySubjectLine]).to eq({
            tile_email.subject => 0,
            tile_email.alt_subject => 0
          })
        end
      end

      describe "when there are logins" do
        it "returns a hash of subject lines and total logins ordered by login count if the Tile Email was created before Reports::TileEmailReport::UNIQUE_LOGIN_SUPPORTED_DATE" do
          3.times do
            tile_email.increment_logins_by_subject_line(tile_email.subject)
          end

          5.times do
            tile_email.increment_logins_by_subject_line(tile_email.alt_subject)
          end

          tile_email.update_attributes(created_at: Reports::TileEmailReport::UNIQUE_LOGIN_SUPPORTED_DATE - 1.day)
          report = new_tile_email_report(tile_email)
          attributes = report.attributes

          expect(attributes[:loginsBySubjectLine]).to eq({
            tile_email.alt_subject => 5,
            tile_email.subject => 3
          })
        end

        it "returns a hash of subject lines and unique logins ordered by login count if the Tile Email was created after Reports::TileEmailReport::UNIQUE_LOGIN_SUPPORTED_DATE" do
          7.times do
            tile_email.increment_unique_logins_by_subject_line(tile_email.subject)
          end

          2.times do
            tile_email.increment_unique_logins_by_subject_line(tile_email.alt_subject)
          end

          tile_email.update_attributes(created_at: Reports::TileEmailReport::UNIQUE_LOGIN_SUPPORTED_DATE + 1.day)
          report = new_tile_email_report(tile_email)
          attributes = report.attributes

          expect(attributes[:loginsBySubjectLine]).to eq({
            tile_email.alt_subject => 2,
            tile_email.subject => 7
          })
        end
      end
    end
  end
end
