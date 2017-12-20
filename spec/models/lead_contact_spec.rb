require 'spec_helper'

describe LeadContact do
  it { is_expected.to belong_to :user }
  it { is_expected.to belong_to :organization }

  it { is_expected.to validate_presence_of :name}
  it { is_expected.to validate_presence_of :email}
  it { is_expected.to validate_presence_of :phone}
  it { is_expected.to validate_presence_of :organization_name}
  it { is_expected.to validate_presence_of :organization_size}

  it "parses phone number correctly before create" do
    lead_contact = FactoryBot.create(:lead_contact, phone: "999-394-3940", status: "", organization_name: "MY COMPANY")

    expect(lead_contact.phone).to eq("9993943940")
    expect(lead_contact.status).to eq("pending")
    expect(lead_contact.organization_name).to eq("My Company")
  end

  describe ".notify!" do
    describe "when a lead contact is created and the lead contact source is Inbound: Signup Request" do
      it "should create a job that notifies sales" do
        LeadContact.create(
          name:    'Lead Contact',
          email:   'sales@leadco.com',
          phone:   '9993939393',
          organization_name: 'AMEX',
          organization_size: '100-500 employees',
          source: 'Inbound: Signup Request',
        )

        open_email 'team@airbo.com'

        expect(current_email.subject).to include('New Inbound Lead: Signup Request')
        [
          'Lead Contact',
          'sales@leadco.com',
          '9993939393',
          'Amex',
          '100-500 employees',
        ].each do |text_piece|
          expect(current_email.body).to include(text_piece)
        end
      end
    end
  end
end
