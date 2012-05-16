require "spec_helper"

describe ActionMailer::Base do
  context "sending mail when logging to DB raises an error" do
    before(:each) do
      OutgoingEmail.stubs(:create).raises("something terrible happened")
      @user = FactoryGirl.create(:user)
    end

    it "should not pass the error up the stack" do
      lambda{DummyMailer.make_me_a_sandwich(@user.id).deliver}.should_not raise_error
    end
  end
end
