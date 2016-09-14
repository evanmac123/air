require 'acceptance/acceptance_helper'

feature "Potential client recieves an invitation to try airbo and clicks link in email", js: true do
  context 'As the first potential client in an organization' do
    context "when I click the onboarding link in the email I received from airbo" do
      it "takes me through the entire onboarding flow" do
        visit onboarding_email_link
      end
    end
  end

  def onboarding_email_link
    "/newairbo?email=test%40test.com&name=Test+Name&onboard=true&organization=Test+Company"
  end
end
