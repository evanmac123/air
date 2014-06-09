require "spec_helper"

describe Mailer do
  it '#invitation contains a do-not-forward warning message' do
    email = Mailer.invitation(FactoryGirl.create :user)
    email.text_part.body.should include('Please do not forward it to others.')
  end
end
