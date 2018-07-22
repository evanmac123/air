require "spec_helper"

describe Mailer do
  it '#invitation contains a do-not-forward warning message' do
    email = Mailer.invitation(FactoryBot.create :user)
    expect(email.body).to include('Please do not forward it.')
  end
end
