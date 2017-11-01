require 'spec_helper'

describe Api::ClientAdmin::TilesDigestAutomatorsController, delay_jobs: true do
  describe "POST create" do
    it "creates a new tiles_digest_automator if none exists" do
      client_admin = FactoryGirl.create(:client_admin)
      sign_in_as(client_admin)

      post(:create, { tiles_digest_automator: {} })

      body = JSON.parse(response.body)
      tiles_digest_automator = TilesDigestAutomator.find(body["tiles_digest_automator"]["id"])

      expect(response.status).to eq(200)
      expect(response.content_type.json?).to eq(true)
      expect(tiles_digest_automator.job.present?).to eq(true)
      expect(tiles_digest_automator.job.run_at).to eq(tiles_digest_automator.deliver_date)
      expect(Delayed::Job.where(queue: "TilesDigestAutomation").count).to eq(1)
    end
  end

  describe "PUT update" do
    context "when user has access" do
      it "updates the automator" do
        client_admin = FactoryGirl.create(:client_admin)
        automator = client_admin.demo.create_tiles_digest_automator(deliver_date: 2.days.from_now)

        sign_in_as(client_admin)

        update_params = {
          id: automator.id,
          tiles_digest_automator: {
            day: 2,
            time: "11",
            frequency_cd: 2,
            follow_up_day: 5,
            include_sms: true,
            include_unclaimed_users: false
          }
        }

        put(:update, update_params)

        body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response.content_type.json?).to eq(true)

        expect(body["tiles_digest_automator"]["day"]).to eq(2)
        expect(body["tiles_digest_automator"]["time"]).to eq("11")
        expect(body["tiles_digest_automator"]["follow_up_day"]).to eq(5)
        expect(body["tiles_digest_automator"]["frequency_cd"]).to eq(2)
        expect(body["tiles_digest_automator"]["include_sms"]).to eq(true)
        expect(body["tiles_digest_automator"]["include_unclaimed_users"]).to eq(false)
      end
    end

    context "when user is in wrong board (outdated session)" do
      it "responds with access denied and helpful flash" do
        site_admin = FactoryGirl.create(:site_admin)
        automator = site_admin.demo.create_tiles_digest_automator(deliver_date: 2.days.from_now)

        other_demo = FactoryGirl.create(:demo, name: "Other Demo")

        site_admin.move_to_new_demo(other_demo)

        sign_in_as(site_admin)

        put(:update, id: automator.id)

        expect(response.status).to eq(403)
        expect(response.content_type.json?).to eq(true)
        expect(response.headers["X-Message-Type"]).to eq(:failure)
        expect(response.headers["X-Message"]).to eq(I18n.t('flashes.failure_outdated_session'))
      end
    end
  end

  describe "DELETE destroy" do
    context "when user has access" do
      it "removes the automator" do
        client_admin = FactoryGirl.create(:client_admin)
        automator = client_admin.demo.create_tiles_digest_automator(deliver_date: 2.days.from_now)

        automator.schedule_delivery

        job_id = automator.job_id

        sign_in_as(client_admin)

        delete(:destroy, id: automator.id)

        expect(response.status).to eq(200)
        expect(response.content_type.json?).to eq(true)
        expect(TilesDigestAutomator.count).to eq(0)
        expect(Delayed::Job.where(id: job_id).present?).to eq(false)
      end
    end

    context "when user is in wrong board (outdated session)" do
      it "responds with access denied and helpful flash" do
        site_admin = FactoryGirl.create(:site_admin)
        automator = site_admin.demo.create_tiles_digest_automator(deliver_date: 2.days.from_now)

        other_demo = FactoryGirl.create(:demo, name: "Other Demo")

        site_admin.move_to_new_demo(other_demo)

        sign_in_as(site_admin)

        delete(:destroy, id: automator.id)

        expect(response.status).to eq(403)
        expect(response.content_type.json?).to eq(true)
        expect(response.headers["X-Message-Type"]).to eq(:failure)
        expect(response.headers["X-Message"]).to eq(I18n.t('flashes.failure_outdated_session'))
      end
    end
  end
end
