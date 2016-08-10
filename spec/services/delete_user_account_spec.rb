require 'spec_helper'
# FIXME: This service is pegged for removal along with the board_settings feature
describe DeleteUserAccount do
  describe "#delete!" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @deleter = DeleteUserAccount.new(@user)
    end

    it "should delete the user" do
      @deleter.delete!
      expect(User.count).to eq(0)
    end

    context "when the user is in at least one paid board" do
      before do
        @user.add_board(FactoryGirl.create(:demo, :paid))
      end

      it "should not delete the user" do
        @deleter.delete!
        expect(User.count).to eq(1)
      end

      it "should set #error_messages" do
        @deleter.delete!
        @deleter.error_messages.should == ["you can't leave a paid board"]
      end
    end
  end
end
