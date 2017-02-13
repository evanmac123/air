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
end
