require 'spec_helper'

RSpec.describe UserOnboardingNotifier, type: :mailer do
  describe 'notify_all' do
    it 'sends mailer to each emal in comma separated string' do
      user_onboarding = FactoryGirl.create(:user_onboarding)
      colleagues = "email@example.com, test@example.com"

      UserOnboardingNotifier.notify_all(user_onboarding, colleagues)

      expect(ActionMailer::Base.deliveries.count).to eq(2)
    end
  end
end
