require 'spec_helper'

describe UserOnboarding do
  context "when an organization has an initialized onboarding" do
    before do
      org = Organization.create(name: "Org")
      @onboarding = Onboarding.create(organization: org)
      @user_one = org.users.create(email: "test@test.com", name: "Test Name")
      @user_onboarding= @onboarding.user_onboardings.create(user: @user_one)
    end

    it "creates an auth hash" do
      expect(@user_onboarding.auth_hash).to_not be_nil
    end

    it "defaults state to 'initial' when created as the first UserOnboarding" do

      expect(@user_onboarding.state).to eq(2)
    end

    it "defaults state to 'view_board' when created as the second..n UserOnboarding" do

      user_two = @onboarding.organization.users.create(email: "tes2t@test.com", name: "Test Nametwo")

      user_onboarding = @onboarding.user_onboardings.create(user: user_two)

      expect(@user_onboarding.state).to eq(2)
    end
  end
end
