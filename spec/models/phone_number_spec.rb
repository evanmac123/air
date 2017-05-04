require 'spec_helper'

describe "PhoneNumber" do
  describe ".normalize" do
    context "when the number already starts with #{PhoneNumber::USA_COUNTRY_CODE}" do
      it "should normalize the number properly" do
        [
          "1-415-261-3077",
          "1 (415) 261-3077",
          "1.415.261.3077",
          "    141x52613+&+&077"
        ].each do |unnormalized_phone_number|
          expect(PhoneNumber.normalize(unnormalized_phone_number)).to eq("+14152613077")
        end
      end
    end

    context "when the number does not already start with #{PhoneNumber::USA_COUNTRY_CODE}" do
      it "should normalize the number properly" do
        [
          "415-261-3077",
          "(415) 261-3077",
          "415.261.3077",
          "     41x52613+&+&077     "
        ].each do |unnormalized_phone_number|
          expect(PhoneNumber.normalize(unnormalized_phone_number)).to eq("+14152613077")
        end
      end
    end

    context "when the number is blank" do
      it "should return nil" do
        [
          "",
          "            ",
          "\t\t\n\t\n"
        ].each do |unnormalized_phone_number|
          expect(PhoneNumber.normalize(unnormalized_phone_number)).to eq(nil)
        end
      end
    end
  end
end
