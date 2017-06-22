require 'spec_helper'

describe ChartMogulService::Remove do
  let(:organization) { Organization.create(name: "Test") }
  let(:cm_remove_service) { ChartMogulService::Remove.new(organization: organization) }

  describe "#remove_from_chart_mogul" do
    it "instantiates a new ChartMogulService::Customer" do
      ChartMogulService::Customer.expects(:new).with(organization: organization).once.returns(stub_everything)

      cm_remove_service.remove_from_chart_mogul
    end

    it "asks an instance of ChartMogulService::Customer to destroy_chart_mogul_customer" do
      ChartMogulService::Customer.any_instance.expects(:destroy_chart_mogul_customer).once

      cm_remove_service.remove_from_chart_mogul
    end
  end

  describe "#remove_chart_mogul_uuids" do
    it "sets the organization.chart_mogul_uuid to nil" do
      organization.expects(:update_attributes).with(chart_mogul_uuid: nil).once

      cm_remove_service.remove_chart_mogul_uuids
    end

    it "sets all related invoices.chart_mogul_uuid to nil" do
      organization.invoices.expects(:update_all).with(chart_mogul_uuid: nil)

      cm_remove_service.remove_chart_mogul_uuids
    end

    it "sets all related invoice_transactions.chart_mogul_uuid to nil" do
      organization.invoice_transactions.expects(:update_all).with(chart_mogul_uuid: nil)

      cm_remove_service.remove_chart_mogul_uuids
    end
  end
end
