require 'spec_helper'

describe TilesDigestTester do
  describe "#deliver_test" do
    before do
      @client_admin = FactoryGirl.create(:client_admin)
    end

    it "attempts to send a test Tile Email and test Follow Up Email if follow_up_day != Never" do
      tiles_digest_form = TilesDigestForm.new(demo: @client_admin.demo, user: @client_admin, params: digest_params)

      tiles_digest_tester = TilesDigestTester.new(digest_form: tiles_digest_form)

      TilesDigestMailer.expects(:delay).twice.returns(TilesDigestMailer)

      TilesDigestMailer.expects(:notify_one).with(
        instance_of(OpenStruct),
        tiles_digest_tester.current_user.id,
        "[Test] #{digest_params[:custom_subject]}",
        TilesDigestMailDigestPresenter
      ).once

      TilesDigestMailer.expects(:notify_one).with(
        instance_of(OpenStruct),
        tiles_digest_tester.current_user.id,
        "[Test] Don't Miss: #{digest_params[:custom_subject]}",
        TilesDigestMailFollowUpPresenter
      ).once


      tiles_digest_tester.deliver_test!
    end

    it "only attempts to send a test Tile Email if follow_up_day == Never" do
      params = digest_params
      params[:follow_up_day] = "Never"
      tiles_digest_form = TilesDigestForm.new(demo: @client_admin.demo, user: @client_admin, params: params)

      tiles_digest_tester = TilesDigestTester.new(digest_form: tiles_digest_form)

      TilesDigestMailer.expects(:delay).once.returns(TilesDigestMailer)

      TilesDigestMailer.expects(:notify_one).with(
        instance_of(OpenStruct),
        tiles_digest_tester.current_user.id,
        "[Test] #{params[:custom_subject]}",
        TilesDigestMailDigestPresenter
      ).once

      tiles_digest_tester.deliver_test!
    end

    it "defaults to the TilesDigest::DEFAULT_DIGEST_SUBJECT if no subject is given" do
      params = digest_params
      params[:custom_subject] = nil
      tiles_digest_form = TilesDigestForm.new(demo: @client_admin.demo, user: @client_admin, params: params)

      tiles_digest_tester = TilesDigestTester.new(digest_form: tiles_digest_form)

      TilesDigestMailer.expects(:delay).twice.returns(TilesDigestMailer)

      TilesDigestMailer.expects(:notify_one).with(
        instance_of(OpenStruct),
        tiles_digest_tester.current_user.id,
        "[Test] #{TilesDigest::DEFAULT_DIGEST_SUBJECT}",
        TilesDigestMailDigestPresenter
      ).once

      TilesDigestMailer.expects(:notify_one).with(
        instance_of(OpenStruct),
        tiles_digest_tester.current_user.id,
        "[Test] Don't Miss: #{TilesDigest::DEFAULT_DIGEST_SUBJECT}",
        TilesDigestMailFollowUpPresenter
      ).once

      tiles_digest_tester.deliver_test!
    end
  end

  def digest_params
    {
      digest_send_to: "true",
      follow_up_day: "Monday",
      custom_subject: "Subject",
      custom_headline: "Headline",
      custom_message: "Intro message"
    }
  end
end
