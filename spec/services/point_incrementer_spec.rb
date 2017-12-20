require 'spec_helper'

describe PointIncrementer do
  describe ".call" do
    it "initializes a PointIncrementer and calls #update_points" do
      user = User.new
      increment = 1
      mock_incrementer = PointIncrementer.new(user, increment)

      PointIncrementer.expects(:new).with(user, increment).returns(mock_incrementer)

      mock_incrementer.expects(:update_points)

      PointIncrementer.call(user: user, increment: increment)
    end
  end

  describe "#update_points" do
    before do
      @user = FactoryBot.create(:user)
    end

    it "updates points and adds ticket if it should" do
      expect(@user.points).to eq(0)
      expect(@user.tickets).to eq(0)

      PointIncrementer.call(user: @user, increment: 20)

      expect(@user.points).to eq(20)
      expect(@user.tickets).to eq(1)
    end
  end
end
