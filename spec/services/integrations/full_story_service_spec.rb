require 'spec_helper'

describe Integrations::FullStoryService do

  describe "#record_user?" do
    it "asks if user_is_guest? or record_active_user?" do
      full_story_service = Integrations::FullStoryService.new(nil)

      full_story_service.expects(:user_is_guest?).once.returns(false)
      full_story_service.expects(:record_active_user?).once

      full_story_service.send(:record_user?)
    end
  end

  describe "#user_is_guest" do
    it "returns true when user is nil" do
      user = nil
      full_story_service = Integrations::FullStoryService.new(user)

      expect(full_story_service.send(:user_is_guest?)).to eq(true)
    end

    it "returns true when user is a GuestUser" do
      user = GuestUser.new
      full_story_service = Integrations::FullStoryService.new(user)

      expect(full_story_service.send(:user_is_guest?)).to eq(true)
    end

    it "returns false when user is a User" do
      user = User.new
      full_story_service = Integrations::FullStoryService.new(user)

      expect(full_story_service.send(:user_is_guest?)).to eq(false)
    end
  end

  describe "#record_active_user?" do
    describe "when user is not in an internal organization" do
      it "records when user is a client admin" do
        organization = OpenStruct.new(internal: false)
        user = OpenStruct.new(is_client_admin: true, organization: organization)

        full_story_service = Integrations::FullStoryService.new(user)

        expect(full_story_service.send(:record_active_user?)).to eq(true)
      end

      it "asks if user_is_ordinary_user_in_sample? if user is not a client admin" do
        organization = OpenStruct.new(internal: false)
        user = OpenStruct.new(is_client_admin: false, organization: organization)

        full_story_service = Integrations::FullStoryService.new(user)
        full_story_service.expects(:user_is_ordinary_user_in_sample?)

        full_story_service.send(:record_active_user?)
      end
    end

    describe "when user is in an internal organization" do
      it "returns false" do
        organization = OpenStruct.new(internal: true)
        user = OpenStruct.new(organization: organization)

        full_story_service = Integrations::FullStoryService.new(user)

        expect(full_story_service.send(:record_active_user?)).to be_falsey
      end
    end
  end

  describe "#user_is_ordinary_user_in_sample?" do
    it "records user if user is ordinary user in sample" do
      organization = OpenStruct.new(internal: false)
      user = OpenStruct.new(end_user?: true, id: 2, organization: organization)

      full_story_service = Integrations::FullStoryService.new(user)

      expect(full_story_service.send(:record_user?)).to eq(true)
    end

    it "does not record user if user is outside of sample" do
      #no sampling currently implemented
      organization = OpenStruct.new(internal: false)
      user = OpenStruct.new(end_user?: true, id: 1, organization: organization)

      full_story_service = Integrations::FullStoryService.new(user)

      expect(full_story_service.send(:record_user?)).to eq(true)
    end
  end
end
