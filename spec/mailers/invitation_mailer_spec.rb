require "spec_helper"

describe Mailer do
  it '#invitation contains a do-not-forward warning message' do
    email = Mailer.invitation(FactoryBot.create :user)
    expect(email.body).to include('Do not forward this')
  end
end
