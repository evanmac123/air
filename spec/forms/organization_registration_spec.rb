require "spec_helper"

describe OrganizationRegistration do
  def registration_params
    {
      "organization_name" => "Org",
      "user_name" => "User",
      "user_email" => "user@example.com",
      "board_name" => "Board",
      "board_template_id" => "2"
    }
  end

  it "crates an org with a board and initial user" do
    registration = OrganizationRegistration.new(registration_params)
    registration.save

    expect(User.first).to eq(registration.user)
    expect(Demo.first).to eq(registration.board)
    expect(Organization.first).to eq(registration.organization)
  end
end
