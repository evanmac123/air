require 'spec_helper'

describe Organization do
  it { should have_many(:subscriptions) }
  it { should have_many(:lead_contacts) }
  it { should have_many(:boards) }
  it { should have_many(:tiles) }
  it { should have_many(:board_memberships) }
  it { should validate_presence_of(:name) }

  it "is valid when complete" do
    o = FactoryBot.build(:organization, :complete)
    expect(o.valid?).to be_truthy
  end

  describe ".before_save" do
    describe "#normalize_blank_values" do
      it "calls method from mixin" do
        Organization.any_instance.expects(:normalize_blank_values).once
        FactoryBot.create(:organization)
      end

      it "forces blank values to nil" do
        org = FactoryBot.create(:organization, email: "")

        expect(org.email).to eq(nil)
      end
    end
  end

  describe ".smb" do
    it "returns a collection of all smb orgs" do
      smb_orgs = FactoryBot.create_list(:organization, 3, company_size_cd: Organization.company_sizes[:smb])
      _enterprise_orgs = FactoryBot.create_list(:organization, 2, company_size_cd: Organization.company_sizes[:enterprise])

      expect(Organization.smb).to eq(smb_orgs)
    end
  end

  describe ".enterprise" do
    it "returns a collection of all enterprise orgs" do
      enterprise_orgs = FactoryBot.create_list(:organization, 3, company_size_cd: Organization.company_sizes[:enterprise])
      _smb_orgs = FactoryBot.create_list(:organization, 2, company_size_cd: Organization.company_sizes[:smb])

      expect(Organization.enterprise).to eq(enterprise_orgs)
    end
  end

  describe ".paid" do
    it "returns a collection of all organizations with paid demos" do
      paid_orgs = FactoryBot.create_list(:organization, 2)
      _paid_demo_1 = FactoryBot.create(:demo, customer_status_cd: Demo.customer_statuses[:paid], organization_id: paid_orgs[0].id)
      _paid_demo_2 = FactoryBot.create(:demo, customer_status_cd: Demo.customer_statuses[:paid], organization_id: paid_orgs[1].id)

      _free_orgs = FactoryBot.create_list(:organization, 2)

      expect(Organization.paid).to eq(paid_orgs)
    end
  end

  describe "#free?" do
    it "returns true if all demos are free or trial" do
      free_org = FactoryBot.create(:organization)
      _free_demo_1 = FactoryBot.create(:demo, customer_status_cd: Demo.customer_statuses[:free], organization_id: free_org.id)
      _free_demo_2 = FactoryBot.create(:demo, customer_status_cd: Demo.customer_statuses[:free], organization_id: free_org.id)
      _trial_demo = FactoryBot.create(:demo, customer_status_cd: Demo.customer_statuses[:trial], organization_id: free_org.id)

      expect(free_org.free?).to eq(true)
    end

    it "returns false if there is a paid demo" do
      free_org = FactoryBot.create(:organization)
      _free_demo_1 = FactoryBot.create(:demo, customer_status_cd: Demo.customer_statuses[:free], organization_id: free_org.id)
      _free_demo_2 = FactoryBot.create(:demo, customer_status_cd: Demo.customer_statuses[:free], organization_id: free_org.id)
      _paid_demo = FactoryBot.create(:demo, customer_status_cd: Demo.customer_statuses[:paid], organization_id: free_org.id)

      expect(free_org.free?).to eq(false)
    end

    it "returns true of org has no demos" do
      org = Organization.new

      expect(org.free?).to eq(true)
    end
  end

  describe "#trial?" do
    it "returns true if there is a trial demo" do
      trial_org = FactoryBot.create(:organization)
      _free_demo_1 = FactoryBot.create(:demo, customer_status_cd: Demo.customer_statuses[:free], organization_id: trial_org.id)
      _trial_demo = FactoryBot.create(:demo, customer_status_cd: Demo.customer_statuses[:trial], organization_id: trial_org.id)

      expect(trial_org.trial?).to eq(true)
    end

    it "returns false if there is no trial demo" do
      org = Organization.new

      expect(org.trial?).to eq(false)
    end
  end

  describe "#paid?" do
    it "returns true if there is a paid demo" do
      paid_org = FactoryBot.create(:organization)
      _free_demo_1 = FactoryBot.create(:demo, customer_status_cd: Demo.customer_statuses[:free], organization_id: paid_org.id)
      _paid_demo = FactoryBot.create(:demo, customer_status_cd: Demo.customer_statuses[:paid], organization_id: paid_org.id)

      expect(paid_org.paid?).to eq(true)
    end

    it "returns false if there is no paid demo" do
      org = Organization.new

      expect(org.paid?).to eq(false)
    end
  end

  describe "#customer_status" do
    it "returns :paid when paid?" do
      paid_org = FactoryBot.create(:organization)
      _free_demo_1 = FactoryBot.create(:demo, customer_status_cd: Demo.customer_statuses[:free], organization_id: paid_org.id)
      _paid_demo = FactoryBot.create(:demo, customer_status_cd: Demo.customer_statuses[:paid], organization_id: paid_org.id)

      expect(paid_org.customer_status).to eq(:paid)
    end

    it "returns :trial when trial?" do
      trial_org = FactoryBot.create(:organization)
      _free_demo_1 = FactoryBot.create(:demo, customer_status_cd: Demo.customer_statuses[:free], organization_id: trial_org.id)
      _trial_demo = FactoryBot.create(:demo, customer_status_cd: Demo.customer_statuses[:trial], organization_id: trial_org.id)

      expect(trial_org.customer_status).to eq(:trial)
    end

    it "returns :free when not paid? nor trial?" do
      org = Organization.new

      expect(org.customer_status).to eq(:free)
    end
  end
end
