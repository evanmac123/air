require 'spec_helper'

describe UserSettingsChangeLog do
  it { should belong_to :user }

  it "should validate email presense if saving_email" do
    uscl = UserSettingsChangeLog.new

    expect(uscl.email).to eql("")
    expect(uscl).to be_valid

    uscl.saving_email = true
    expect(uscl).to_not be_valid
    expect(uscl.errors[:email]).to eql(["can't be blank"])
  end

  it "should validate email uniqueness" do
    email = "present@email.com"
    FactoryGirl.create :user, email: email

    uscl = UserSettingsChangeLog.new(email: "fine@email.com")
    expect(uscl).to be_valid

    uscl.email = email
    expect(uscl).to_not be_valid
    expect(uscl.errors[:email]).to eql(["already exists"])
  end

  context "#save email" do
    it "should generate token" do
      uscl = UserSettingsChangeLog.new
      uscl.save_email "some@email.com"
      expect(uscl.email).to eql("some@email.com")
      expect(uscl.email_token).to be_present
    end
  end
end
