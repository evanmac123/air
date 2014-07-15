require 'spec_helper'

describe DeleteUserAccount do
  describe "#delete!" do
    before do
      @user = FactoryGirl.create(:user)
      @deleter = DeleteUserAccount.new(@user)
    end

    it "should make the user non-loginnable" do
      @deleter.delete!
      @user.reload.encrypted_password.should == "****NO LOGIN****"
    end

    it "should spawn a DJ to actually delete the user" do
      user_id = @user.id
      original_dj_count = Delayed::Job.count

      @deleter.delete!
      (Delayed::Job.count > original_dj_count).should be_true

      User.where(id: user_id).should be_present
      crank_dj_clear
      User.where(id: user_id).should_not be_present
    end

    it "should return truthiness" do
      @deleter.delete!.should be_true
    end

    context "when the user is in at least one paid board" do
      before do
        @user.add_board(FactoryGirl.create(:demo, :paid))
      end

      it "should return falsiness" do
        @deleter.delete!.should be_false
      end

      it "should spawn no DJs" do
        original_dj_count = Delayed::Job.count
        @deleter.delete!
        Delayed::Job.count.should == original_dj_count
      end

      it "should leave the password undisturbed" do
        original_password = @user.encrypted_password
        @deleter.delete!
        @user.reload.encrypted_password.should == original_password
      end

      it "should set #error_messages" do
        @deleter.delete!
        @deleter.error_messages.should == ["you can't leave a paid board"]
      end
    end
  end
end
