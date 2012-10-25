require 'spec_helper'
include SteakHelperMethods

describe Admin::Reports::ActivitiesController do
  describe '#create' do
    before(:each) do
      FactoryGirl.create :demo, id: 1
      clearance_signin_as_admin
      request.env["HTTP_REFERER"] = '/'  # So controller's "redirect_to :back" doesn't barf

      post :create, demo_id: 1
    end

    it 'should add a send-report-activity email task to the DelayedJobs table' do
      # 2 jobs are stuffed into the DJ queue before the email one => 'DJ.last'
      # Actual entry looks something like the following ('m' modifier => 'multiline' => '.' can match newline characters)
      # "!ruby/object:Delayed::PerformableMethod \nargs: \n- larry@hengage.com\nmethod_name: :send_email\nobject: !ruby/object:Report::Activity \n  demo_id: 1\n"
      Delayed::Job.last.handler.should =~ /send_email.*Report::Activity/m
    end

    it 'should assign the correct message to the flash' do
      flash[:success].should =~ /An Activity Report has been sent/
    end
  end
end
