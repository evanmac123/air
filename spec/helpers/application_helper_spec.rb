require 'rails_helper'

describe ApplicationHelper do
  describe "#non_site_admin" do
    it "returns true if user is not a site admin" do
      user = FactoryGirl.build(:user)

      expect(helper.non_site_admin(user)).to be true
    end

    it "returns false if user is a site admin" do
      user = FactoryGirl.build(:site_admin)

      expect(helper.non_site_admin(user)).to be_falsey
    end
  end

  describe "#get_user_type" do
    it "returns 'guest' if user is nil" do
      user = nil

      expect(helper.get_user_type(user)).to eq('guest')
    end

    it "returns 'guest' if user is a GuestUser" do
      user = GuestUser.new

      expect(helper.get_user_type(user)).to eq('guest')
    end

    it "returns 'user' if user is an end user" do
      user = FactoryGirl.build(:user)

      expect(helper.get_user_type(user)).to eq('user')
    end

    it "returns 'client_admin' if user is a client_admin" do
      user = FactoryGirl.build(:client_admin)

      expect(helper.get_user_type(user)).to eq('client_admin')
    end

    it "returns 'client_admin' if user is a site_admin" do
      user = FactoryGirl.build(:site_admin)

      expect(helper.get_user_type(user)).to eq('client_admin')
    end
  end
end
