require "spec_helper"

describe Mailer do
  describe '#invitation' do
    subject { Mailer.invitation(FactoryGirl.create :user) }
    it { should have_body_text 'Please do not forward it to others.' }
  end
end
