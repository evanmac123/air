require 'spec_helper'

describe ChartMogulService::Customer do
  let(:organization) { Organization.create(name: "Test") }
  let(:cm_customer_service) { ChartMogulService::Customer.new(organization: organization) }

  describe "#retrieve_customer" do
    it "asks ChartMogul to retrieve customer" do
      cm_customer_service
      organization.update_attributes(chart_mogul_uuid: "cm_cus_uuid")

      ChartMogul::Customer.expects(:retrieve).with("cm_cus_uuid")

      cm_customer_service.send(:retrieve_customer)
    end
  end

  describe "#find_or_create_chart_mogul_customer" do
    describe "when chart_mogul_customer already present" do
      it "returns chart_mogul_customer" do
        cm_customer_service.expects(:chart_mogul_customer).twice.returns(:fake_chart_mogul_customer)

        expect(cm_customer_service.find_or_create_chart_mogul_customer).to eq(:fake_chart_mogul_customer)
      end
    end

    describe "when chart_mogul_customer is not present" do
      it "creates a chart_mogul_customer" do
        cm_customer_service.expects(:create_chart_mogul_customer)

        cm_customer_service.find_or_create_chart_mogul_customer
      end
    end
  end

  describe "#create_or_update_chart_mogul_customer" do
    describe "when chart_mogul_customer is already present" do
      it "updates the chart_mogul_customer" do
        cm_customer_service.expects(:chart_mogul_customer).returns(:fake_chart_mogul_customer)

        cm_customer_service.expects(:update_chart_mogul_customer)

        cm_customer_service.create_or_update_chart_mogul_customer
      end
    end

    describe "when chart_mogul_customer is not present" do
      it "creates a chart_mogul_customer" do
        cm_customer_service.expects(:create_chart_mogul_customer)

        cm_customer_service.create_or_update_chart_mogul_customer
      end
    end
  end

  describe "#update_chart_mogul_customer" do
    it "updates attributes of chart_mogul_customer" do
      fake_chart_mogul_customer = OpenStruct.new(name: nil, email: nil, free_trial_started_at: nil)

      fake_chart_mogul_customer.expects(:update!)
      cm_customer_service.chart_mogul_customer = fake_chart_mogul_customer

      cm_customer_service.update_chart_mogul_customer
    end
  end

  describe "#create_chart_mogul_customer" do
    it "asks ChartMogul to create a customer and updates the internal org" do
      fake_chart_mogul_customer = OpenStruct.new(uuid: "cm_cus_uuid")

      ChartMogul::Customer.expects(:create!).with(
        data_source_uuid: ChartMogul::DEFAULT_DATA_SOURCE,
        external_id: organization.id,
        name: organization.name,
        email: organization.email,
        lead_created_at: organization.created_at,
        free_trial_started_at: organization.free_trial_started_at
      ).returns(fake_chart_mogul_customer)

      cm_customer_service.expects(:add_chart_mogul_uuid_to_org)

      cm_customer_service.create_chart_mogul_customer
    end
  end

  describe "#destroy_chart_mogul_customer" do
    describe "when a chart_mogul_customer is present" do
      it "asks ChartMogul to delete the customer from ChartMogul" do
        fake_chart_mogul_customer = ChartMogul::Customer.new

        cm_customer_service.stubs(:chart_mogul_customer).returns(fake_chart_mogul_customer)

        fake_chart_mogul_customer.expects(:destroy!)

        cm_customer_service.destroy_chart_mogul_customer
      end
    end

    describe "when a chart_mogul_customer is not present" do
      it "does nothing" do
        expect(cm_customer_service.destroy_chart_mogul_customer).to eq(nil)
      end
    end
  end

  describe "#add_chart_mogul_uuid_to_org" do
    describe "when a chart_mogul_customer is present" do
      it "updates the organization with the chart_mogul_uuid" do
        fake_chart_mogul_customer = ChartMogul::Customer.new

        cm_customer_service.stubs(:chart_mogul_customer).returns(fake_chart_mogul_customer)
        fake_chart_mogul_customer.stubs(:uuid).returns("test_uuid")

        cm_customer_service.send(:add_chart_mogul_uuid_to_org)

        expect(organization.chart_mogul_uuid).to eq("test_uuid")
      end
    end

    describe "when a chart_mogul_customer is not present" do
      it "does nothing" do
        expect(cm_customer_service.send(:add_chart_mogul_uuid_to_org)).to eq(nil)
      end
    end
  end
end
