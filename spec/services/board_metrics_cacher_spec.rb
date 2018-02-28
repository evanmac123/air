require 'spec_helper'

describe BoardMetricsCacher do
  describe ".call" do
    it "initiates BoardMetricsCacher and calls cache" do
      ca = FactoryBot.create(:client_admin)
      mock_cacher = mock("BoardMetricsCacher")

      BoardMetricsCacher.expects(:new).with(ca.demo).returns(mock_cacher)
      mock_cacher.expects(:cache)

      BoardMetricsCacher.call(board: ca.demo)
    end
  end

  describe "#cache" do
    before do
      Timecop.freeze(Time.local(1990))
    end

    after do
      Timecop.return
    end

    it "sets cache expiration and asks BoardMetricsGenerator to cache reports" do
      ca = FactoryBot.create(:client_admin)
      cacher = BoardMetricsCacher.new(ca.demo)
      redis_key = cacher.redis_metrics_key

      redis_key.expects(:call).with(:get)
      redis_key.expects(:call).with(:set, Time.now)
      redis_key.expects(:call).with(:expire, 12.minutes)
      BoardMetricsGeneratorJob.expects(:perform_later).with(board: ca.demo)

      cacher.cache
    end

    it "does not set cache if already set" do
      ca = FactoryBot.create(:client_admin)
      cacher = BoardMetricsCacher.new(ca.demo)
      redis_key = cacher.redis_metrics_key

      redis_key.expects(:call).with(:get).returns(true)
      BoardMetricsGeneratorJob.expects(:perform_later).never

      cacher.cache
    end
  end
end
