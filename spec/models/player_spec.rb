require 'spec_helper'

describe Player do
  it { should belong_to(:demo) }
end

describe Player, ".alphabetical" do
  before do
    @jobs  = Factory(:player, :name => "Steve Jobs")
    @gates = Factory(:player, :name => "Bill Gates")
  end

  it "finds all players, sorted alphaetically" do
    Player.alphabetical.should == [@gates, @jobs]
  end
end
