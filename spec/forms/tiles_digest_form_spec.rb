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
    @tiles_digest_form = TilesDigestForm.new(demo: @client_admin.demo, user: @client_admin, params: digest_params)
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
        tiles_digest_form = TilesDigestForm.new(demo: @client_admin.demo, user: @client_admin, params: params)

        expect(tiles_digest_form.unclaimed_users_also_get_digest).to eq(true)
      end

      it "returns false if params[:digest_send_to] returns 'false'" do
        params = { digest_send_to: "false" }
        tiles_digest_form = TilesDigestForm.new(demo: @client_admin.demo, user: @client_admin, params: params)

        expect(tiles_digest_form.unclaimed_users_also_get_digest).to eq(false)
      end
    end
  end

  describe "#submit_send_test_digest" do
    it "asks TileDigestTester to deliver a test" do
      mock_tiles_digest_tester = OpenStruct.new(deliver_test: true)
      TilesDigestTester.expects(:new).with(digest_form: @tiles_digest_form).returns(mock_tiles_digest_tester)

      mock_tiles_digest_tester.expects(:deliver_test!)

      @tiles_digest_form.submit_send_test_digest
    end
  end
end
