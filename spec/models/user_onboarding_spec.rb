require 'spec_helper'

describe UserOnboarding do
  context "when an organization has an initialized onboarding" do
    before do
      org = Organization.create(name: "Org")
      @onboarding = Onboarding.create(organization: org)
      @user_one = org.users.create(email: "test@test.com", name: "Test Name")
    end

    it "defaults state to 'initial' when created as the first UserOnboarding" do
      user_onboarding = @onboarding.user_onboardings.create(user: @user_one)

      expect(user_onboarding.state).to eq("initial")
    end

    it "defaults state to 'view_board' when created as the second..n UserOnboarding" do
      @onboarding.user_onboardings.create(user: @user_one)

      user_two = @onboarding.organization.users.create(email: "tes2t@test.com", name: "Test Nametwo")

      user_onboarding = @onboarding.user_onboardings.create(user: user_two)

      expect(user_onboarding.state).to eq("view_board")
    end
  end
end
