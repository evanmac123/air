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

  context "activity session tracking" do
    controller do
      def index
        render inline: 'hey hey'
      end
    end

    before do
      user = FactoryGirl.create(:user, email: 'fred@foobar.com')
      user.password = user.password_confirmation = "foobar"
      user.save!
      Timecop.freeze
    end

    after(:each) do
      Timecop.return
    end

    let (:threshold) {ApplicationController::ACTIVITY_SESSION_THRESHOLD} # this would get real tedious to type

    def do_real_login
      # We want to exercise the #authorize method, so we can't use the backdoor
      # in these tests.
      visit new_session_path
      fill_in "session[email]", with: "fred@foobar.com"
      fill_in "session[password]", with: "foobar"

      crank_dj_clear
      FakeMixpanelTracker.clear_tracked_events

      click_button "Log In"
    end

    context "when a user signs in" do
      it "should log a new activity session" do
        do_real_login
        crank_dj_clear
        FakeMixpanelTracker.should have_event_matching('Activity Session - New')
      end
    end

    context "when a user does something that triggers authorize after #{ApplicationController::ACTIVITY_SESSION_THRESHOLD} seconds or more" do
      it "should log a new activity session" do
        do_real_login
        crank_dj_clear
        FakeMixpanelTracker.clear_tracked_events

        Timecop.travel(threshold - 1)
        crank_dj_clear
        FakeMixpanelTracker.should_not have_event_matching('Activity Session - New')

        $FRUITBAT = true
        Timecop.travel(threshold)
        get :index
        crank_dj_clear
        FakeMixpanelTracker.events_matching('Activity Session - New').should have(1).ping

        Timecop.travel(threshold + 1)
        get :index
        crank_dj_clear
        FakeMixpanelTracker.events_matching('Activity Session - New').should have(2).pings
      end
    end
  end
end
