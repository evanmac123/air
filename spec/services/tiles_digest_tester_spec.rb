require 'spec_helper'

describe TilesDigestTester do
  describe "#deliver_test" do
    before do
      @client_admin = FactoryBot.create(:client_admin)
    end

    it "attempts to send a test Tile Digest and test Follow Up Email if follow_up_day != Never" do
      tiles_digest_form = TilesDigestForm.new(demo: @client_admin.demo, user: @client_admin, params: digest_params)

      tiles_digest_tester = TilesDigestTester.new(digest_form: tiles_digest_form)

      mock_delivery = ActionMailer::Base::NullMail.new

      TilesDigestMailer.expects(:notify_one).with(
        instance_of(OpenStruct),
        tiles_digest_tester.current_user.id,
        "[Test] #{digest_params[:custom_subject]}",
        "TilesDigestPresenter"
      ).once.returns(mock_delivery)

      TilesDigestMailer.expects(:notify_one).with(
        instance_of(OpenStruct),
        tiles_digest_tester.current_user.id,
        "[Test] Don't Miss: #{digest_params[:custom_subject]}",
        "FollowUpDigestPresenter"
      ).once.returns(mock_delivery)

      mock_delivery.expects(:deliver_now).twice

      tiles_digest_tester.deliver_test
    end

    it "only attempts to send a test Tile Digest if follow_up_day == Never" do
      params = digest_params
      params[:follow_up_day] = "Never"
      tiles_digest_form = TilesDigestForm.new(demo: @client_admin.demo, user: @client_admin, params: params)

      tiles_digest_tester = TilesDigestTester.new(digest_form: tiles_digest_form)

      mock_delivery = ActionMailer::Base::NullMail.new

      TilesDigestMailer.expects(:notify_one).with(
        instance_of(OpenStruct),
        tiles_digest_tester.current_user.id,
        "[Test] #{params[:custom_subject]}",
        "TilesDigestPresenter"
      ).once.returns(mock_delivery)

      tiles_digest_tester.deliver_test
    end

    it "defaults to the TilesDigest::DEFAULT_DIGEST_SUBJECT if no subject is given" do
      params = digest_params
      params[:custom_subject] = nil
      tiles_digest_form = TilesDigestForm.new(demo: @client_admin.demo, user: @client_admin, params: params)

      tiles_digest_tester = TilesDigestTester.new(digest_form: tiles_digest_form)

      mock_delivery = ActionMailer::Base::NullMail.new

      TilesDigestMailer.expects(:notify_one).with(
        instance_of(OpenStruct),
        tiles_digest_tester.current_user.id,
        "[Test] #{TilesDigest::DEFAULT_DIGEST_SUBJECT}",
        "TilesDigestPresenter"
      ).once.returns(mock_delivery)

      TilesDigestMailer.expects(:notify_one).with(
        instance_of(OpenStruct),
        tiles_digest_tester.current_user.id,
        "[Test] Don't Miss: #{TilesDigest::DEFAULT_DIGEST_SUBJECT}",
        "FollowUpDigestPresenter"
      ).once.returns(mock_delivery)

      tiles_digest_tester.deliver_test
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
