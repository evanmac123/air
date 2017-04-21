require "spec_helper"

describe TilesDigestForm do

  def digest_params
    {
      digest_send_to: "true",
      follow_up_day: "Monday",
      custom_subject: "Subject",
      custom_headline: "Headline",
      custom_message: "Intro message"
    }
  end

  before do
    @client_admin = FactoryGirl.create(:client_admin)
    @tiles_digest_form = TilesDigestForm.new(@client_admin, digest_params)
  end

  describe "attr_readers" do
    it "calls current_user" do
      expect(@tiles_digest_form.current_user).to eq(@client_admin)
    end

    it "calls follow_up_day" do
      expect(@tiles_digest_form.follow_up_day).to eq(digest_params[:follow_up_day])
    end

    it "calls custom_message" do
      expect(@tiles_digest_form.custom_message).to eq(digest_params[:custom_message])
    end

    it "calls custom_subject" do
      expect(@tiles_digest_form.custom_subject).to eq(digest_params[:custom_subject])
    end

    it "calls alt_custom_subject" do
      expect(@tiles_digest_form.alt_custom_subject).to eq(digest_params[:alt_custom_subject])
    end

    it "calls custom_headline" do
      expect(@tiles_digest_form.custom_headline).to eq(digest_params[:custom_headline])
    end

    describe "#unclaimed_users_also_get_digest" do
      it "returns true if params[:digest_send_to] returns 'true'" do
        params = { digest_send_to: "true" }
        tiles_digest_form = TilesDigestForm.new(@client_admin, params)

        expect(tiles_digest_form.unclaimed_users_also_get_digest).to eq(true)
      end

      it "returns false if params[:digest_send_to] returns 'false'" do
        params = { digest_send_to: "false" }
        tiles_digest_form = TilesDigestForm.new(@client_admin, params)

        expect(tiles_digest_form.unclaimed_users_also_get_digest).to eq(false)
      end
    end
  end

  describe "#send_test_email_to_self" do
    it "attempts to send a test Tile Email and test Follow Up Email if follow_up_day != Never" do
      TilesDigestMailer.expects(:delay).twice.returns(TilesDigestMailer)

      TilesDigestMailer.expects(:notify_one).with(
        instance_of(OpenStruct),
        @tiles_digest_form.current_user.id,
        "[Test] #{@tiles_digest_form.custom_subject}",
        TilesDigestMailDigestPresenter
      ).once

      TilesDigestMailer.expects(:notify_one).with(
        instance_of(OpenStruct),
        @tiles_digest_form.current_user.id,
        "[Test] Don't Miss: #{@tiles_digest_form.custom_subject}",
        TilesDigestMailFollowUpPresenter
      ).once

      @tiles_digest_form.send_test_email_to_self
    end

    it "only attempts to send a test Tile Email if follow_up_day == Never" do
      params = digest_params
      params[:follow_up_day] = "Never"
      tiles_digest_form = TilesDigestForm.new(@client_admin, params)

      TilesDigestMailer.expects(:delay).once.returns(TilesDigestMailer)

      TilesDigestMailer.expects(:notify_one).with(
        instance_of(OpenStruct),
        @tiles_digest_form.current_user.id,
        "[Test] #{@tiles_digest_form.custom_subject}",
        TilesDigestMailDigestPresenter
      ).once

      tiles_digest_form.send_test_email_to_self
    end

    it "defaults to the TilesDigest::DEFAULT_DIGEST_SUBJECT if no subject is given" do
      params = digest_params
      params[:custom_subject] = nil
      tiles_digest_form = TilesDigestForm.new(@client_admin, params)

      TilesDigestMailer.expects(:delay).twice.returns(TilesDigestMailer)

      TilesDigestMailer.expects(:notify_one).with(
        instance_of(OpenStruct),
        @tiles_digest_form.current_user.id,
        "[Test] #{TilesDigest::DEFAULT_DIGEST_SUBJECT}",
        TilesDigestMailDigestPresenter
      ).once

      TilesDigestMailer.expects(:notify_one).with(
        instance_of(OpenStruct),
        @tiles_digest_form.current_user.id,
        "[Test] Don't Miss: #{TilesDigest::DEFAULT_DIGEST_SUBJECT}",
        TilesDigestMailFollowUpPresenter
      ).once

      tiles_digest_form.send_test_email_to_self
    end
  end
end
