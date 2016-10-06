require 'spec_helper'


describe OnboardingInitializer do

    before do
      topic = FactoryGirl.create(:topic_board, :valid)
      @onit = OnboardingInitializer.new({email: "test@test1.com", organization: "Test Com", name: "Test User", board_id: topic.board.id})
    end
    describe "#assemble" do
      it "creates user" do
        expect{@onit.assemble}.to change{User.count}.by(1)
      end


      it "creates user_onboarding" do
        expect{@onit.assemble}.to change{UserOnboarding.count}.by(1)
      end

      it "creates a demo" do
        expect{@onit.assemble}.to change{Demo.count}.by(1)
      end

      it "creates an organization " do
        expect{@onit.assemble}.to change{Organization.count}.by(1)
      end

      it "creates a board_membership" do
        expect{@onit.assemble}.to change{BoardMembership.count}.by(1)
      end

      it "creates an onaboarding" do
        expect{@onit.assemble}.to change{Onboarding.count}.by(1)
      end
    end
    describe "#save" do

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
