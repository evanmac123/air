require 'spec_helper'

describe "any controller descended from ApplicationController" do
  context "redirecting" do
    controller do
      skip_before_filter :authorize

      def index
        render :inline => 'some nonsense'
      end
    end

    before do
      # We don't want to route this anonymous dummy controller, so have it lie
      # about its name and claim to be a controller that does exist and has a
      # routed index action, for use with url_for type URL generation.
      @controller.stubs(:controller_name).returns("acts")
      $test_force_ssl = true
    end

    after do
      $test_force_ssl = false
    end

    context "when an http request is made" do
      context "and no subdomain is specified" do
        it "should redirect to the corresponding HTTPS endpoint, with www subdomain" do
          get :index
          response.should redirect_to("https://www.test.host/activity")
        end
      end

      context "and a subdomain is specified" do
        before do
          request.host = "secure.test.host"
        end

        it "should redirect to the corresponding HTTPS endpoint, using the original subdomain" do
          get :index
          response.should redirect_to("https://secure.test.host/activity")
        end
      end

      context "with query parameters" do
        it "should preserve them" do
          get :index, :foo => "foo", :bar => "bar"
          response.location.should =~ /\?bar=bar\&foo=foo$/
        end
      end
    end
  end

  context "invalid ping logger" do
    controller do
      skip_before_filter :authorize

      def index
        render :inline => 'some nonsense'
      end
    end

    before do
      # We don't want to route this anonymous dummy controller, so have it lie
      # about its name and claim to be a controller that does exist and has a
      # routed index action, for use with url_for type URL generation.
      @controller.stubs(:controller_name).returns("acts")
      $test_force_ssl = true
    end

    after do
      $test_force_ssl = false
    end

    it "should log ping without user" do
      # expect(Rails.logger).to receive(:warn).with("INVALID USER PING SENT")
      # debugger
      Rails.logger.should_receive(:info).with("some message")
      get :index
    end
  end
end
