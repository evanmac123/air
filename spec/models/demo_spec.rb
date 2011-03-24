require 'spec_helper'

describe Demo do
  it { should have_many(:users) }
end

describe Demo, "#welcome_message" do
  before(:each) do
    @demo = Factory :demo
    @user = Factory :user, :demo => @demo
  end

  context "when the demo has no custom welcome message" do
    before(:each) do
      @demo.custom_welcome_message.should be_nil
    end

    it "should return a reasonable default" do
      @demo.welcome_message(@user).should == "You've joined the #{@demo.company_name} game! Your unique ID is #{@user.sms_slug} (text MYID for a reminder). To play, send texts to this #. Send a text HELP for help."    
    end
  end

  context "when the demo has a custom welcome message" do
    before(:each) do
      @demo.custom_welcome_message = "Derp derp! Let's play!"
    end

    it "should use that" do
      @demo.welcome_message(@user).should == "Derp derp! Let's play!"
    end
  end
end

describe Demo, "#game_over?" do
  before(:each) do
    @demo = Factory :demo
  end

  context "for a demo with no ending time set" do
    before(:each) do
      @demo.ends_at.should be_nil
    end

    it "should return false" do
      @demo.game_over?.should be_false
    end
  end

  context "for a demo with an ending time set" do
    before(:each) do
      @demo.ends_at = Time.parse("2010-05-01 12:00:00 UTC")
    end

    after(:each) do
      Timecop.return
    end

    context "before the ending time" do
      before(:each) do
        Timecop.freeze(Time.parse("2010-05-01 11:59:59 UTC"))
      end

      it "should return false" do
        @demo.game_over?.should be_false
      end
    end

    context "after that ending time" do
      before(:each) do
        Timecop.freeze(Time.parse("2010-05-01 12:00:00 UTC"))
      end

      it "should return true" do
        @demo.game_over?.should be_true
      end
    end
  end
end

describe Demo, ".alphabetical" do
  before do
    @red_sox  = Factory(:demo, :company_name => "Red Sox")
    @gillette = Factory(:demo, :company_name => "Gillette")
  end

  it "finds all demos, sorted alphaetically" do
    Demo.alphabetical.should == [@gillette, @red_sox]
  end
end
