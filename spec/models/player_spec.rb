require 'spec_helper'

describe Player do
  it { should belong_to(:demo) }
end

describe Player, "#invitation_code" do
  before do
    Timecop.travel("1/1/11") do
      @player   = Factory(:player)
      @expected = Digest::SHA1.hexdigest("--#{Time.now.utc}--#{@player.email}--")
    end
  end

  it "should create unique invitation code" do
    @player.invitation_code.should == @expected
  end
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

describe Player, "#send_welcome_sms" do
  subject { Factory(:player) }
  let(:phone_number) { "(508) 740-7520" }

  before do
    Twilio::SMS.stubs(:create)
    subject.join_game(phone_number)
  end

  it "normalizes and saves the phone number" do
    subject.reload.phone_number.should == "+15087407520"
  end

  it "sends welcome SMS" do
    Twilio::SMS.should have_received(:create)
  end
end
