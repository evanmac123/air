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
end
