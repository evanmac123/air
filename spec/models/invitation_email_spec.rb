require 'spec_helper'

describe "InvitationEmail" do

  it "has bullet defaults" do
    InvitationEmail.bullet_defaults.class.should == Hash
    InvitationEmail.bullet_defaults.length.should == 3
  end

  it "selects either the default text or the demo-specific text" do
    User.delete_all
    Demo.delete_all
    @monopoly = FactoryGirl.create(:demo)
    @lucy = FactoryGirl.create(:user, demo: @monopoly)
    appends = ['1', '2', '3']
    # First with a generic demo (no custom fields set)
    appends.each do |append|
      default_text = InvitationEmail.bullet_defaults[append]
      demo_specific_text = eval("InvitationEmail.bullet_#{append}(@monopoly)")
      demo_specific_text.should == InvitationEmail.wrap_and_sanitize(default_text)
    end
    
    # Now set custom appends
    appends.each do |append|
      eval "@monopoly.invitation_bullet_#{append} = append"
    end

    @monopoly.save!

    appends.each do |append|
      demo_specific_text = eval("InvitationEmail.bullet_#{append}(@monopoly)")
      demo_specific_text.should == append
    end
  end

  context "#wrap_and_sanitize (Converting raw input into multiple lines)" do
    it "turns carriage returns into <p> tags" do
      bullet = "First line\r\nSecond line"
      InvitationEmail.wrap_and_sanitize(bullet).should == "First line<br>Second line"
    end

    it "strips all tags except <i> and <b> sets" do
      bullet = "<script>malicious</script><b>code</b><br><p><h1>really</h1><i>IS</i><pre>fun"
      result = InvitationEmail.wrap_and_sanitize(bullet)
      result.should == "<b>code</b>really<i>IS</i>fun"
      result.should be_html_safe
    end

    it "strips tags and inserts <br> tags at the same time" do
      bullet = "<h1>You are at the</h1>\r\nforefront of humanity<footer>"
      result = InvitationEmail.wrap_and_sanitize(bullet)
      result.should == "You are at the<br>forefront of humanity"
      result.should be_html_safe
    end

    it "returns the defaults correctly" do
      demo = Demo.new
      InvitationEmail.bullet_1(demo).should == "Finding tiles"
      InvitationEmail.bullet_2(demo).should == "Eating fruits and veggies"
      last = InvitationEmail.bullet_3(demo)
      last.should == "Exercising and making other<br>healthy choices"
      last.should be_html_safe
    end
  end

  context "#gsub_referrer" do
    it "should replace [referrer] with the first name" do
      sailor = User.new(name: 'Popeye the Sailor')
      string = "[referrer] and "
      InvitationEmail.gsub_referrer(string, sailor).should == "Popeye the Sailor and "
    end
  end

  context "blurb" do
    before(:each) do
      @demo = Demo.new
      @person = User.new(name: "George Bates")
    end

    it "returns the default email blurb when none saved" do
      @demo = Demo.new
      default_blurb = InvitationEmail.blurb(@demo)
      default_blurb.class.should == ActiveSupport::SafeBuffer
      default_blurb.should == InvitationEmail.default_blurb(@demo)

      default_blurb_with_referrer = InvitationEmail.blurb(@demo, @person)
      default_blurb_with_referrer.class.should == ActiveSupport::SafeBuffer
      manual_default = InvitationEmail.default_blurb_with_referrer(@demo)
      default_blurb_with_referrer.should == InvitationEmail.gsub_referrer(manual_default, @person)
    end

    it "returns the saved blurb when present, and does not escape b,i tags" do 
      string_of_text = "Enjoy our <b><i>boomerang</i></b> game!"
      @demo.invitation_blurb = string_of_text
      output = InvitationEmail.blurb(@demo)
      output.should == string_of_text
      output.class.should == ActiveSupport::SafeBuffer

      string_with_tag = "[referrer] likes you!"
      @demo.invitation_blurb_with_referrer = string_with_tag
      output_with_referrer = InvitationEmail.blurb(@demo, @person)
      output_with_referrer.should == "George Bates likes you!"
      output_with_referrer.class.should == ActiveSupport::SafeBuffer
    end

    it "strips all tags when calling bullets or blurbs for plain email" do
      string_of_text = "<b><i>Hi</i></b>"
      @demo.invitation_blurb = string_of_text
      InvitationEmail.plain_blurb(@demo).should == "Hi"
      InvitationEmail.blurb(@demo).should == string_of_text 
    end
  end

  context "plain bullets" do
    before(:each) do
      @bingo = Demo.new
      [1,2,3].each do |num|
        method = "invitation_bullet_" + num.to_s + "="
        madness = "<b><i>#{num}</i></b>"
        @bingo.send(method, madness)
      end
    end

    it "should strip tags out of a plain bullet" do
      InvitationEmail.plain_bullet_1(@bingo).should == "1"
      InvitationEmail.plain_bullet_2(@bingo).should == "2"
      InvitationEmail.plain_bullet_3(@bingo).should == "3"
    end
  end

  context "subject" do 
    before(:each) do
      @tictactoe = Demo.new
      @clown = User.new(name: "Charlie Brown")
    end

    it "should return a default subject" do
      InvitationEmail.subject(@tictactoe).should == InvitationEmail.default_subject(@tictactoe)
      manual_default = InvitationEmail.default_subject_with_referrer(@tictactoe)

      InvitationEmail.subject_with_referrer(@tictactoe, @clown).should == InvitationEmail.gsub_referrer(manual_default, @clown)
    end
    
    it "should select saved subject" do
      subject = "Come play Tic Tac Toe with me"
      @tictactoe.invitation_subject = subject
      InvitationEmail.subject(@tictactoe).should == subject

      subject_with_referrer = "[referrer] wants to play Tic Tac Toe with you"
      @tictactoe.invitation_subject_with_referrer = subject_with_referrer
      InvitationEmail.subject_with_referrer(@tictactoe, @clown).should == "Charlie Brown wants to play Tic Tac Toe with you"
    end
  end
end
