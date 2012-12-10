require 'acceptance/acceptance_helper'

feature "Make sure when I email someone else's claim code from my claimed account and registered email that it gives referrer credit to them, and does not change their email to mine." do
  before do
    @demo = FactoryGirl.create(:demo)
    @suzie = FactoryGirl.create(:claimed_user, demo: @demo )
    @fred = FactoryGirl.create(:claimed_user, demo: @demo, claim_code: 'abcde')
  end

  scenario "Suzie emails us fred's claim code" do
    body = @fred.claim_code
    email_originated_message_received(@suzie.email, 'cool subject', body)
    crank_dj_clear
    @fred.reload.email.should_not == @suzie.email
  end
end
