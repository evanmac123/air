require "spec_helper"

describe String do
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
