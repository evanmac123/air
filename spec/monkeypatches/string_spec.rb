require "spec_helper"

describe String do

  describe "#is_email_address?" do
    it "should disallow anything that's not a valid email address" do
      expect("".is_email_address?).to eq(nil)
      expect("abcdefg@hi".is_email_address?).to eq(nil)
      expect("&you@mine.com".is_email_address?).to eq(nil)
      expect("#64@me.com".is_email_address?).to eq(nil)
      expect("a@a..com".is_email_address?).to eq(nil)
      expect("^hithere@by.com".is_email_address?).to eq(nil)
      expect("there @by.com".is_email_address?).to eq(nil)
      expect("?are@you.com".is_email_address?).to eq(nil)
      expect("~who@you.com".is_email_address?).to eq(nil)
      expect("you@me. Com".is_email_address?).to eq(nil)
    end
  end
  
  describe "#is_email_address?" do
    it "should allow any conceivable email address" do
      expect("a@a.com".is_email_address?).to be_a Integer
      expect("abcdeADVV-me@aa.a.b.C-v.com".is_email_address?).to be_a Integer
      expect("abracadabralonglonglongemailaddressPPQ@a.a.a.a.com".is_email_address?).to be_a Integer
      expect("you+me%us@angry.com".is_email_address?).to be_a Integer
      expect("chloek@yahoo-inc.com".is_email_address?).to be_a Integer
      expect("a@a.com".is_email_address?).to be_a Integer
      expect("a@a.com".is_email_address?).to be_a Integer
    end
  end
  
  describe "#like_escape" do
    it "should escape % and _ symbols with backslashes" do
      expect("".like_escape).to eq("")
      expect("hey".like_escape).to eq("hey")
      expect("hey there".like_escape).to eq("hey there")
      expect("hey_there@yahoo.com".like_escape).to eq("hey\\_there@yahoo.com")
      expect("hey%_there@yahoo.com".like_escape).to eq("hey\\%\\_there@yahoo.com")
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
          expect(blank_string.as_pretty_phone).to eq("")
        end
      end
    end

    context "of a phone number in canonical form" do
      it "should return a nicely formatted phone number" do
        expect("+14152613077".as_pretty_phone).to eq("(415) 261-3077")
      end
    end
  end
end
