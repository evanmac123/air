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

describe Player, "#invite" do
  subject { Factory(:player) }

  context "when added to demo" do
    it { should_not be_invited }
  end

  context "when invited" do
    let(:invitation) { stub('invitation') }

    before do
      Mailer.stubs(:invitation => invitation)
      invitation.stubs(:deliver)
      subject.invite
    end

    it "sends invitation to player" do
      Mailer.should     have_received(:invitation).with(subject)
      invitation.should have_received(:deliver)
    end

    it { should be_invited }
  end
end
