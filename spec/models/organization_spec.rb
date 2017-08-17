require 'spec_helper'

describe Organization do

  it "is valid when complete" do
    o = FactoryGirl.build(:organization, :complete)
    expect(o.valid?).to be_truthy
  end

  describe ".before_save" do
    describe "#normalize_blank_values" do
      it "calls method from mixin" do
        Organization.any_instance.expects(:normalize_blank_values).once
        FactoryGirl.create(:organization)
      end

      it "forces blank values to nil" do
        org = FactoryGirl.create(:organization, email: "")

        expect(org.email).to eq(nil)
      end
    end
  end

  describe ".smb" do
    it "returns a collection of all smb orgs" do
      smb_orgs = FactoryGirl.create_list(:organization, 3, company_size_cd: Organization.company_sizes[:smb])
      _enterprise_orgs = FactoryGirl.create_list(:organization, 2, company_size_cd: Organization.company_sizes[:enterprise])

      expect(Organization.smb).to eq(smb_orgs)
    end
  end

  describe ".enterprise" do
    it "returns a collection of all enterprise orgs" do
      enterprise_orgs = FactoryGirl.create_list(:organization, 3, company_size_cd: Organization.company_sizes[:enterprise])
      _smb_orgs = FactoryGirl.create_list(:organization, 2, company_size_cd: Organization.company_sizes[:smb])

      expect(Organization.enterprise).to eq(enterprise_orgs)
    end
  end

  describe ".paid" do
    it "returns a collection of all organizations with paid demos" do
      paid_orgs = FactoryGirl.create_list(:organization, 2)
      _paid_demo_1 = FactoryGirl.create(:demo, customer_status_cd: Demo.customer_statuses[:paid], organization_id: paid_orgs[0].id)
      _paid_demo_2 = FactoryGirl.create(:demo, customer_status_cd: Demo.customer_statuses[:paid], organization_id: paid_orgs[1].id)

      _free_orgs = FactoryGirl.create_list(:organization, 2)

      expect(Organization.paid).to eq(paid_orgs)
    end
  end

  describe '#oldest_demo' do
    let(:organization) { FactoryGirl.create(:organization, :complete) }
    let(:demo) { FactoryGirl.build(:demo, organization: organization) }
    let(:demo2) { FactoryGirl.build(:demo, organization: organization) }

    it 'returns oldest demo if it exists' do
      demo.save!

      Timecop.travel(Time.now + 3.hours)

      demo2.save!

      Timecop.return

      expect(organization.oldest_demo).to eql(demo)
    end
  end
end
