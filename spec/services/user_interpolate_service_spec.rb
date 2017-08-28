require 'spec_helper'

describe UserInterpolateService do
  let(:user) { FactoryGirl.create(:user, name: "Test User") }

  describe "#interpolate" do
    it "interpolates default keywords" do
      user_interpolate_service = UserInterpolateService.new(string: "Hey {{name}}!", user: user)

      user_interpolate_service.expects(:interpolate_name).once
      user_interpolate_service.expects(:interpolate_airbo_access_link).once

      user_interpolate_service.interpolate
    end

    it "returns the interpolated message" do
      user_interpolate_service = UserInterpolateService.new(string: "Hey {{name}}!", user: user)

      interpolated_message = user_interpolate_service.interpolate

      expect(interpolated_message).to eq("Hey Test!")
    end
  end

  describe "#interpolate_name" do
    it "returns interpolates {{name}} for user.first_name" do
      user_interpolate_service = UserInterpolateService.new(string: "Hey {{name}}!", user: user)

      interpolated_message = user_interpolate_service.interpolate_name

      expect(interpolated_message).to eq("Hey Test!")
    end
  end

  describe "#interpolate_airbo_access_link" do
    it "interpolates {{link_to_airbo}} for the user's airbo access link" do
      user_interpolate_service = UserInterpolateService.new(string: "Visit {{link_to_airbo}}", user: user)

      interpolated_message = user_interpolate_service.interpolate_airbo_access_link

      expected_result = "Visit <a href='http://example.com/invitations/#{user.invitation_code}?demo_id=#{user.demo.id}&email_type='>Airbo</a>"

      expect(interpolated_message).to eq(expected_result)
    end
  end
end
