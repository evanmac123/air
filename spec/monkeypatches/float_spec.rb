require "spec_helper"

describe Float do

  describe "#as_rounded_percentage" do
    it "converts the floating number into a rounded percent" do
      expect(0.123.as_rounded_percentage).to eq("12%")
      expect(0.127.as_rounded_percentage).to eq("13%")
    end
  end

end
