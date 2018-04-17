require 'rails_helper'

RSpec.describe FollowUpDigestBulkMailJob, type: :job do
  let(:demo) { FactoryBot.create :demo, allow_unsubscribes: true }

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
    FactoryBot.create(:tile, demo: demo, headline: 'Headline 1', status: Tile::DRAFT, supporting_content: 'supporting_content_1')

    FactoryBot.create(:tile, demo: demo, headline: 'Headline 2', status: Tile::DRAFT, supporting_content: 'supporting_content_2')

    FactoryBot.create(:tile, demo: demo, headline: 'Headline 3', status: Tile::DRAFT, supporting_content: 'supporting_content_3')

    FactoryBot.create(:tile, demo: demo, headline: "Archive Tile", status: Tile::ARCHIVE)  # This guy shouldn't show up in the email

    demo.tiles
  end

  let(:digest) { TilesDigest.create(demo: demo, sender: claimed_user, tiles: tiles, sent_at: Date.current + 2.days) }

  describe "#perform" do
    it "should send the appropriate tiles to each user" do
      digest.update_attributes(include_unclaimed_users: true)

      digest.create_follow_up_digest_email(send_on: Date.current)

      FollowUpDigestBulkMailJob.perform_now

      expect(ActionMailer::Base.deliveries.size).to eq(2)

      ActionMailer::Base.deliveries.each do |mail|
        demo.tiles.active.each { |t|
          expect(mail.to_s.include?(t.headline)).to eq(true)
          expect(mail.to_s.include?(t.supporting_content)).to eq(true)
        }
      end
    end

    it 'should be delivered only to users who did no tiles' do
      demo = FactoryBot.create :demo
      sender = FactoryBot.create(:client_admin, demo: demo)

      john = FactoryBot.create :claimed_user, demo: demo, name: 'John',   email: 'john@beatles.com'
      _paul = FactoryBot.create :user,         demo: demo, name: 'Paul',   email: 'paul@beatles.com'
      _george = FactoryBot.create :claimed_user, demo: demo, name: 'George', email: 'george@beatles.com'
      ringo = FactoryBot.create :user,         demo: demo, name: 'Ringo',  email: 'ringo@beatles.com'

      tiles    = FactoryBot.create_list :tile, 3, demo: demo
      tile_ids = tiles.collect(&:id)

      digest = TilesDigest.create(demo: demo, sender: sender, tile_ids: tile_ids, sent_at: Time.current, include_unclaimed_users: true)

      digest.create_follow_up_digest_email(send_on: Date.current)

      FactoryBot.create :tile_completion, user: john,  tile: tiles[0]
      FactoryBot.create :tile_completion, user: john,  tile: tiles[1]
      FactoryBot.create :tile_completion, user: ringo, tile: tiles[2]
      FactoryBot.create :tile_completion, user: sender, tile: tiles[2]

      FollowUpDigestBulkMailJob.perform_now

      expect(ActionMailer::Base.deliveries.count).to eq(2)

      recipients = ActionMailer::Base.deliveries.map(&:to).flatten.sort
      subjects = ActionMailer::Base.deliveries.map(&:subject).flatten.uniq

      expect(recipients).to eq(['george@beatles.com', 'paul@beatles.com'])
      expect(subjects).to eq(["Don't Miss: New Tiles"])
    end

    it "should not deliver to users who did not get the original digest" do
      demo = FactoryBot.create(:demo)
      FactoryBot.create(:tile, demo: demo, status: Tile::DRAFT)

      users_to_deliver_to = FactoryBot.create_list(:user, 2, demo: demo)

      digest = TilesDigest.create(demo: demo, sender: users_to_deliver_to.first, sent_at: Time.current, include_unclaimed_users: true, tiles: Tile.all)

      digest.create_follow_up_digest_email(send_on: Date.current)

      _users_to_not_deliver_to = FactoryBot.create_list(:user, 2, demo: demo)

      FollowUpDigestBulkMailJob.perform_now

      delivery_addresses = ActionMailer::Base.deliveries.map(&:to).flatten.sort
      expect(delivery_addresses).to eq(users_to_deliver_to.map(&:email).sort)
    end

    context "when a custom subject is used in the original" do
      it "should base the subject on that" do
        custom_original_digest_subject = "Et tu, Brute?"

        user = FactoryBot.create(:user)
        tile = FactoryBot.create(:tile, demo: user.demo)

        digest = TilesDigest.create(demo: user.demo, sender: user, tile_ids: [tile.id], subject: custom_original_digest_subject, include_unclaimed_users: true, sent_at: Time.current)

        digest.create_follow_up_digest_email(
          send_on: Date.current
        )

        FollowUpDigestBulkMailJob.perform_now

        open_email(user.email)
        expect(current_email.subject).to eq("Don't Miss: #{custom_original_digest_subject}")
      end
    end

    context "when a custom subject is not used in the original" do
      it "should have a reasonable default" do
        sender = FactoryBot.create(:client_admin)
        user = FactoryBot.create(:claimed_user)

        tile = FactoryBot.create(:tile, demo: user.demo)

        digest = TilesDigest.create(demo: user.demo, sender: sender, tile_ids: [tile.id], include_unclaimed_users: true, sent_at: Time.current)

        digest.create_follow_up_digest_email(
          send_on: Date.current
        )

        FollowUpDigestBulkMailJob.perform_now

        open_email(user.email)
        expect(current_email.subject).to eq("Don't Miss: New Tiles")
      end
    end

    context "when a custom headline is used in the original" do
      it "should use the same for the followup" do
        sender = FactoryBot.create(:client_admin)
        user = FactoryBot.create(:claimed_user)
        tile = FactoryBot.create(:tile, demo: user.demo)

        digest = TilesDigest.create(demo: user.demo, sender: sender, tile_ids: [tile.id], headline: 'Kneel before Zod', include_unclaimed_users: true, sent_at: Time.current)

        digest.create_follow_up_digest_email(
          send_on: Date.current
        )

        FollowUpDigestBulkMailJob.perform_now

        open_email(user.email)
        expect(current_email.body.include?('Kneel before Zod')).to eq(true)
      end
    end

    context "when a custom headline is not used in the original" do
      it "should have a reasonable default" do
        sender = FactoryBot.create(:client_admin)
        user = FactoryBot.create(:claimed_user)
        tile = FactoryBot.create(:tile, demo: user.demo)

        digest = TilesDigest.create(demo: user.demo, sender: sender, tile_ids: [tile.id], include_unclaimed_users: true, sent_at: Time.current)

        digest.create_follow_up_digest_email(
          send_on: Date.current
        )

        FollowUpDigestBulkMailJob.perform_now

        open_email(user.email)
        expect(current_email.body.include?("Don&#39;t miss your new tiles")).to eq(true)
      end
    end

    it 'should not send to a user who is unsubscribed' do
      followup_board = FactoryBot.create(:demo)
      tile = FactoryBot.create(:tile, demo: followup_board)
      unmuted_user = FactoryBot.create(:user, demo: followup_board)
      muted_user   = FactoryBot.create(:user, demo: followup_board)

      muted_user.board_memberships.update_all(notification_pref_cd: BoardMembership.notification_prefs[:unsubscribe])

      digest = TilesDigest.create(demo: followup_board, sender: unmuted_user, tile_ids: [tile.id], sent_at: Time.current, include_unclaimed_users: true)

      digest.create_follow_up_digest_email(
        send_on: Date.current,
      )

      FollowUpDigestBulkMailJob.perform_now

      expect(ActionMailer::Base.deliveries.size).to eq(1)
      expect(ActionMailer::Base.deliveries.map(&:to).flatten.first).to eq(unmuted_user.email)
    end
  end
end
