require 'rails_helper'

RSpec.describe TilesDigestBulkMailJob, type: :job do
  describe '#perform' do
    let(:demo) { FactoryBot.create :demo, tile_digest_email_sent_at: Date.yesterday, allow_unsubscribes: true }

    let!(:claimed_user) do
      user = FactoryBot.create(:claimed_user,
        name: 'John Campbell',
        email: 'john@campbell.com',
        demo: demo
      )

      user.board_memberships.update_all(joined_board_at: Time.current)
      user
    end

    let!(:unclaimed_user) do
      FactoryBot.create(:user,
        name: 'Irma Thomas',
        email: 'irma@thomas.com',
        demo: demo
      )
    end

    let(:tiles) do
      FactoryBot.create(:tile, demo: demo, headline: 'Headline 1', status: Tile::ACTIVE, activated_at: Time.current, supporting_content: 'supporting_content_1')

      FactoryBot.create(:tile, demo: demo, headline: 'Headline 2', status: Tile::ACTIVE, activated_at: Time.current, supporting_content: 'supporting_content_2')

      FactoryBot.create(:tile, demo: demo, headline: 'Headline 3', status: Tile::ACTIVE, activated_at: Time.current, supporting_content: 'supporting_content_3')

      FactoryBot.create(:tile, demo: demo, headline: "Archive Tile", status: Tile::ARCHIVE)  # This guy shouldn't show up in the email

      demo.tiles
    end

    let(:digest) { TilesDigest.create(demo: demo, sender: claimed_user, tiles: tiles, sent_at: Date.current + 2.days) }

    it 'should not send to a user who is unsubscribed' do
      digest_users = [claimed_user]
      TilesDigestBulkMailJob.perform_now(digest)

      expect(ActionMailer::Base.deliveries.count).to eq(digest_users.count)

      ActionMailer::Base.deliveries.clear
      claimed_user.board_memberships.update_all(notification_pref_cd: BoardMembership.notification_prefs[:unsubscribe])
      TilesDigestBulkMailJob.perform_now(digest)

      expect(ActionMailer::Base.deliveries).to be_empty
    end

    it 'should only send to claimed users by default' do
      TilesDigestBulkMailJob.perform_now(digest)

      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end

    it 'should only send to claimed and unclaimed_users when the digest specifies to include_unclaimed_users' do
      digest.update_attributes(include_unclaimed_users: true)
      TilesDigestBulkMailJob.perform_now(digest)

      expect(ActionMailer::Base.deliveries.count).to eq(2)
    end

    it "should A/B test subject lines if the digest as an alt_subject" do
      digest.update_attributes(include_unclaimed_users: true, subject: "Subject A", alt_subject: "Subject B")

      TilesDigestBulkMailJob.perform_now(digest)

      expect(ActionMailer::Base.deliveries.count).to eq(2)
      b_digest = ActionMailer::Base.deliveries.first
      a_digest = ActionMailer::Base.deliveries.last

      expect(a_digest.subject).to eq(digest.subject)
      expect(b_digest.subject).to eq(digest.alt_subject)
    end

    it "should send the appropriate tiles to each user" do
      digest.update_attributes(include_unclaimed_users: true)
      TilesDigestBulkMailJob.perform_now(digest)

      expect(ActionMailer::Base.deliveries.size).to eq(2)

      ActionMailer::Base.deliveries.each do |mail|
        demo.tiles.active.each { |t|
          expect(mail.to_s.include?(t.headline)).to eq(true)
        }
      end
    end
  end
end
