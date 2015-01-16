require 'spec_helper'

describe TileViewing do
  it { should belong_to(:user) }
  it { should belong_to(:tile) }
  
  describe TileViewing, "#increment" do
    before do
      @tv = FactoryGirl.create :tile_viewing
    end

    it "views should = 1 by default" do
      @tv.views.should == 1
    end

    it "should increment views" do
      @tv.increment
      @tv.views.should == 2
    end
  end

  describe TileViewing, ".add" do
    before do
      @tile = FactoryGirl.create :tile
      @user = FactoryGirl.create :user
    end

    it "should create tile viewing or increase views" do
      tv = TileViewing.add @tile, @user
      tv.views.should == 1

      tv = TileViewing.add @tile, @user
      tv.views.should == 2
    end
  end

  describe TileViewing, ".views" do
    before do
      @tile = FactoryGirl.create :tile
      @user = FactoryGirl.create :user
    end

    it "should return number of views" do
      num = TileViewing.views @tile, @user
      num.should == 0

      TileViewing.add @tile, @user
      num = TileViewing.views @tile, @user
      num.should == 1
    end
  end
end
