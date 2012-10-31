require 'spec_helper'

describe "any controller descended from ApplicationController" do
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

  context "@old_browser gets set based on browser version" do
    it "returns true with IE6" do
      request.env['HTTP_USER_AGENT'] = "Mozilla/5.0 (Windows; U; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 2.0.50727)"
      get :index
      assigns['old_browser'].should be_true
    end

   it "returns true with IE7" do
      request.env['HTTP_USER_AGENT'] = "Mozilla/4.0 (compatible; MSIE 7.0b; Windows NT 6.0)"
      get :index
      assigns['old_browser'].should be_true
    end
    
    it "returns false with IE8" do
      request.env['HTTP_USER_AGENT'] = "Mozilla/5.0 (compatible; MSIE 8.0; Windows NT 5.2; Trident/4.0; Media Center PC 4.0; SLCC1; .NET CLR 3.0.04320)"
      get :index
      assigns['old_browser'].should be_false
    end

  it "returns false with mozilla 6.0" do
      request.env['HTTP_USER_AGENT'] = "Mozilla/5.0 (Windows NT 5.1; rv:6.0) Gecko/20100101 Firefox/6.0 FirePHP/0.6"
      get :index
      assigns['old_browser'].should be_false
    end

   it "returns false with safari 5.0" do
      request.env['HTTP_USER_AGENT'] = "Mozilla/5.0 (Windows; U; Windows NT 6.1; sv-SE) AppleWebKit/533.19.4 (KHTML, like Gecko) Version/5.0.3 Safari/533.19.4"
      get :index
      assigns['old_browser'].should be_false
    end
  end

end
