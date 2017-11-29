require 'spec_helper'

describe Api::ClientAdmin::TilesDigestAutomatorsController, delay_jobs: true do
  render_views

  describe "PUT update" do
    context "when no automator is saved yet" do
      it "creates a new tiles_digest_automator" do
        client_admin = FactoryGirl.create(:client_admin)
        sign_in_as(client_admin)

        put(:update, { demo_id: client_admin.demo.id, tiles_digest_automator: {}, format: :json })
        body = JSON.parse(response.body)
        tiles_digest_automator = TilesDigestAutomator.find(body["tiles_digest_automator"]["id"])

        expect(response.status).to eq(200)
        expect(tiles_digest_automator.job.present?).to eq(true)
        expect(tiles_digest_automator.job.run_at).to eq(tiles_digest_automator.deliver_date)
        expect(Delayed::Job.where(queue: "TilesDigestAutomation").count).to eq(1)
      end
    end

    context "when user has access" do
      it "updates the automator" do
        client_admin = FactoryGirl.create(:client_admin)
        _automator = client_admin.demo.create_tiles_digest_automator(deliver_date: 2.days.from_now)

        sign_in_as(client_admin)

        update_params = {
          demo_id: client_admin.demo.id,
          tiles_digest_automator: {
            day: 2,
            time: "11",
            frequency_cd: 2,
            has_follow_up: false,
            include_sms: true,
            include_unclaimed_users: false
          }
        }

        put(:update, update_params.merge({ format: :json }))

        body = JSON.parse(response.body)

        expect(response.status).to eq(200)

        expect(body["tiles_digest_automator"]["day"]).to eq(2)
        expect(body["tiles_digest_automator"]["time"]).to eq("11")
        expect(body["tiles_digest_automator"]["has_follow_up"]).to eq(false)
        expect(body["tiles_digest_automator"]["frequency_cd"]).to eq(2)
        expect(body["tiles_digest_automator"]["include_sms"]).to eq(true)
        expect(body["tiles_digest_automator"]["include_unclaimed_users"]).to eq(false)
      end

      it "returns a decorated sendAtTime" do
        client_admin = FactoryGirl.create(:client_admin)
        sign_in_as(client_admin)

        update_params = {
          demo_id: client_admin.demo.id,
          tiles_digest_automator: {}
        }

        put(:update, update_params.merge({ format: :json }))

        body = JSON.parse(response.body)

        expect(body["helpers"]["sendAtTime"]).to eq(subject.tiles_digest_last_sent_or_scheduled_message)
      end
    end

    context "when user is in wrong board (outdated session)" do
      it "responds with access denied and helpful flash" do
        site_admin = FactoryGirl.create(:site_admin)
        automator = site_admin.demo.create_tiles_digest_automator(deliver_date: 2.days.from_now)

        other_demo = FactoryGirl.create(:demo, name: "Other Demo")

        site_admin.move_to_new_demo(other_demo)

        sign_in_as(site_admin)

        put(:update, demo_id: automator.demo.id, format: :json)

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

        delete(:destroy, demo_id: client_admin.demo.id, format: :json)

        expect(response.status).to eq(200)
        expect(TilesDigestAutomator.count).to eq(0)
        expect(Delayed::Job.where(id: job_id).present?).to eq(false)
      end


      it "returns a decorated sendAtTime" do
        client_admin = FactoryGirl.create(:client_admin)
        _automator = client_admin.demo.create_tiles_digest_automator(deliver_date: 2.days.from_now)

        sign_in_as(client_admin)

        delete(:destroy, demo_id: client_admin.demo.id, format: :json)

        body = JSON.parse(response.body)

        expect(body["helpers"]["sendAtTime"]).to eq(subject.tiles_digest_last_sent_or_scheduled_message)
      end
    end

    context "when user is in wrong board (outdated session)" do
      it "responds with access denied and helpful flash" do
        site_admin = FactoryGirl.create(:site_admin)
        automator = site_admin.demo.create_tiles_digest_automator(deliver_date: 2.days.from_now)

        other_demo = FactoryGirl.create(:demo, name: "Other Demo")

        site_admin.move_to_new_demo(other_demo)

        sign_in_as(site_admin)

        delete(:destroy, demo_id: automator.demo.id, format: :json)

        expect(response.status).to eq(403)
        expect(response.content_type.json?).to eq(true)
        expect(response.headers["X-Message-Type"]).to eq(:failure)
        expect(response.headers["X-Message"]).to eq(I18n.t('flashes.failure_outdated_session'))
      end
    end
  end
end
