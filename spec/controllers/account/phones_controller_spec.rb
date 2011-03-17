require 'spec_helper'

describe Account::PhonesController do
  context "#update" do
    before(:each) do
      @controller.current_user = Factory :user
    end

    context "in response to an XHR" do
      before(:each) do
        @params = {:user => {:phone_number => '(415) 261-3077'}}
      end

      it "should return just the new phone number, normalized" do
        xhr :put, :update, @params
        response.body.should == "+14152613077"
      end
    end
  end
end
