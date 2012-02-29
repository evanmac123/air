require "spec_helper"

describe String do

  describe "#is_email_address?" do
    it "should disallow anything that's not a valid email address" do
      "".is_email_address?.should == nil
      "abcdefg@hi".is_email_address?.should == nil
      "&you@mine.com".is_email_address?.should == nil
      "#64@me.com".is_email_address?.should == nil
      "a@a..com".is_email_address?.should == nil
      "^hithere@by.com".is_email_address?.should == nil
      "there @by.com".is_email_address?.should == nil
      "?are@you.com".is_email_address?.should == nil
      "~who@you.com".is_email_address?.should == nil
      "you@me. Com".is_email_address?.should == nil
    end
  end
  
  describe "#is_email_address?" do
    it "should allow any conceivable email address" do
      "a@a.com".is_email_address?.should be_a Integer
      "abcdeADVV-me@aa.a.b.C-v.com".is_email_address?.should be_a Integer
      "abracadabralonglonglongemailaddressPPQ@a.a.a.a.com".is_email_address?.should be_a Integer
      "you+me%us@angry.com".is_email_address?.should be_a Integer
      "chloek@yahoo-inc.com".is_email_address?.should be_a Integer
      "a@a.com".is_email_address?.should be_a Integer
      "a@a.com".is_email_address?.should be_a Integer
    end
  end
  
  describe "#like_escape" do
    it "should escape % and _ symbols with backslashes" do
      "".like_escape.should == ""
      "hey".like_escape.should == "hey"
      "hey there".like_escape.should == "hey there"
      "hey_there@yahoo.com".like_escape.should == "hey\\_there@yahoo.com"
      "hey%_there@yahoo.com".like_escape.should == "hey\\%\\_there@yahoo.com"
    end
  end

  describe "#as_pretty_phone" do
    context "of a blank string" do
      it "should return an empty string" do
        [
          "",
          "      ",
          "\n\n  \t    "
        ].each do |blank_string|
          blank_string.as_pretty_phone.should == ""
        end
      end
    end

    context "of a phone number in canonical form" do
      it "should return a nicely formatted phone number" do
        "+14152613077".as_pretty_phone.should == "(415) 261-3077"
      end
    end
  end
end
