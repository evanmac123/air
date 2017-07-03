require 'spec_helper'

describe ChartMogulService::Plan do
  let(:organization) { Organization.create(name: "Test") }
  let(:plan) { SubscriptionPlan.create(name: "Test Plan", interval_count: 1, interval_cd: 0) }

  describe "class methods" do
    describe ".dispatch_create" do
      it "initializes a ChartMogulService::Plan" do
        ChartMogulService::Plan.expects(:new).once.with(plan).returns(stub_everything)

        ChartMogulService::Plan.dispatch_create(subscription_plan: plan)
      end

      it "calls create_chart_mogul_plan_and_update_internal_plan on a ChartMogulService::Plan" do
        ChartMogulService::Plan.any_instance.expects(:create_chart_mogul_plan_and_update_internal_plan).once

        ChartMogulService::Plan.dispatch_create(subscription_plan: plan)
      end
    end

    describe ".dispatch_update" do
      it "initializes a ChartMogulService::Plan" do
        ChartMogulService::Plan.expects(:new).once.with(plan).returns(stub_everything)

        ChartMogulService::Plan.dispatch_update(subscription_plan: plan)
      end

      it "calls update_chart_mogul_plan_name on a ChartMogulService::Plan" do
        ChartMogulService::Plan.any_instance.expects(:update_chart_mogul_plan_name).once

        ChartMogulService::Plan.dispatch_update(subscription_plan: plan)
      end
    end
  end

  describe "instance methods" do
    let(:cm_plan_service) { ChartMogulService::Plan.new(plan) }

    describe "#create_chart_mogul_plan_and_update_internal_plan" do
      it "does nothing if chart_mogul_plan is already set" do
        cm_plan_service.stubs(:chart_mogul_plan).returns(true)

        expect(cm_plan_service.create_chart_mogul_plan_and_update_internal_plan).to eq(nil)
      end

      describe "when chart_mogul_plan is not set" do
        it "calls create_chart_mogul_plan" do
          cm_plan_service.expects(:create_chart_mogul_plan).once.returns(stub_everything)

          cm_plan_service.create_chart_mogul_plan_and_update_internal_plan
        end

        it "calls update_internal_plan_uuid" do
          cm_plan_service.stubs(:create_chart_mogul_plan)

          cm_plan_service.expects(:update_internal_plan_uuid).once.returns(stub_everything)

          cm_plan_service.create_chart_mogul_plan_and_update_internal_plan
        end

        it "returns chart_mogul_plan" do
          cm_plan_service.stubs(:create_chart_mogul_plan)
          cm_plan_service.stubs(:update_internal_plan_uuid)

          cm_plan_service.expects(:chart_mogul_plan).twice

          cm_plan_service.create_chart_mogul_plan_and_update_internal_plan
        end
      end
    end

    describe "#update_chart_mogul_plan_name" do
      describe "chart_mogul_plan is present" do
        before do
          ChartMogulService::Plan.any_instance.stubs(:find_plan_by_uuid).returns(OpenStruct.new(name: "fake_chart_mogul_plan"))
        end

        it "sets the chart_mogul_plan name to the subscription_plan name" do
          cm_plan_service.update_chart_mogul_plan_name
          expect(cm_plan_service.chart_mogul_plan.name).to eq(plan.name)
        end

        it "calls update! on teh chart_mogul_plan" do
          cm_plan_service.chart_mogul_plan.expects(:update!).once
          cm_plan_service.update_chart_mogul_plan_name
        end
      end

      describe "chart_mogul_plan is not present" do
        it "does nothing and returns nil" do
          expect(cm_plan_service.update_chart_mogul_plan_name).to eq(nil)
        end
      end
    end

    describe "private methods" do
      describe "#create_chart_mogul_plan" do
        it "asks ChartMogul to create a plan" do
          ChartMogul::Plan.expects(:create!).with(
            data_source_uuid: ChartMogul::DEFAULT_DATA_SOURCE,
            name: plan.name,
            interval_count: plan.interval_count,
            interval_unit: plan.interval,
            external_id: plan.id
          ).once

          cm_plan_service.send(:create_chart_mogul_plan)
        end

        it "sets @chart_mogul_plan to the returned ChartMogul plan" do
          ChartMogul::Plan.expects(:create!).returns("fake_chart_mogul_plan")

          cm_plan_service.send(:create_chart_mogul_plan)

          expect(cm_plan_service.chart_mogul_plan).to eq("fake_chart_mogul_plan")
        end
      end
    end

    describe "#update_internal_plan_uuid" do
      it "sets internal plan's chart_mogul_uuid" do
        cm_plan_service.stubs(:chart_mogul_plan).returns(OpenStruct.new(uuid: "test_uuid"))

        cm_plan_service.send(:update_internal_plan_uuid)

        expect(plan.chart_mogul_uuid).to eq("test_uuid")
      end
    end

    describe "#find_plan_by_uuid" do
      it "does nothing if chart_mogul_uuid is nil" do
        plan.update_attributes(chart_mogul_uuid: nil)

        expect(cm_plan_service.send(:find_plan_by_uuid)).to eq(nil)
      end

      it "asks ChartMogul to retrieve plan by uuid if chart_mogul_uuid is present" do
        cm_plan_service
        plan.update_attributes(chart_mogul_uuid: "fake_plan_uuid")

        ChartMogul::Plan.expects(:retrieve).with("fake_plan_uuid").once

        cm_plan_service.send(:find_plan_by_uuid)
      end
    end
  end
end
