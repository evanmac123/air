require 'spec_helper'
#TODO refactor when I actually understand how this works.!

class AnyController < UserBaseController; end

describe "any controller descended from ApplicationController" do
  context "redirecting" do
    controller do

      skip_before_filter :authorize!

      def index
        render :inline => 'some nonsense'
      end
    end

    before do
      # We don't want to route this anonymous dummy controller, so have it lie
      # about its name and claim to be a controller that does exist and has a
      # routed index action, for use with url_for type URL generation.
      subject.stubs(:ping)

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
          expect(response).to redirect_to("https://www.test.host/activity")
        end
      end

      context "and a subdomain is specified" do
        before do
          request.host = "secure.test.host"
        end

        it "should redirect to the corresponding HTTPS endpoint, using the original subdomain" do
          get :index
          expect(response).to redirect_to("https://secure.test.host/activity")
        end
      end

      context "with query parameters" do
        it "should preserve them" do
          get :index, :foo => "foo", :bar => "bar"
          expect(response.location).to match(/\?bar=bar\&foo=foo$/)
        end
      end
    end
  end
end
