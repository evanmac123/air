require 'spec_helper'

describe Admin::OrganizationRegistrationsController do
  describe "POST create" do
    it "saves an OrganizationRegistration" do
      admin = FactoryBot.create(:site_admin)
      sign_in_as(admin)

      mock_registration = OpenStruct.new(user: "user")

      OrganizationRegistration.expects(:new).with(registration_params["organization_registration"]).returns(mock_registration)

      mock_registration.expects(:save).returns(true)
      OrganizationRegistrationCompleter.expects(:call).with(mock_registration, admin)
      subject.expects(:flash_create_success).with(mock_registration.user)

      post :create, registration_params

      expect(response.status).to eq(302)
    end
  end

  def registration_params
    {
      "organization_registration" => {
        "organization_name" => "Org",
        "user_name" => "User",
        "user_email" => "user@example.com",
        "board_name" => "Board",
        "board_template_id" => "2"
      }
    }
  end
end
