require 'spec_helper'


describe OnboardingInitializer do

  describe "#save" do
    before do
      FactoryGirl.create(:demo)
      @onit = OnboardingInitializer.new({email: "test@test1.com", organization: "Test Com", name: "Test User", board_id: Demo.first.id})
    end

    it "creates and valid object" do
      expect{@onit.save}.to change{User.count}.by(1)
    end

    it "creates and valid object" do
      expect{@onit.save}.to change{UserOnboarding.count}.by(1)
    end

    it "creates and valid object" do
      expect{@onit.save}.to change{Demo.count}.by(1)
    end

    it "creates and valid object" do
      expect{@onit.save}.to change{Organization.count}.by(1)
    end

    it "creates and valid object" do
      expect{@onit.save}.to change{BoardMembership.count}.by(1)
    end

    it "creates and valid object" do
      expect{@onit.save}.to change{Onboarding.count}.by(1)
    end
  end

end
