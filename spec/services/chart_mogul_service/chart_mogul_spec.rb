require 'spec_helper'

describe ChartMogul do
  # ChartMogul integration was designed with ChartMogul gem version 1.1.5. Consult docs before upgrading.

  it "is expected version" do
    expect(ChartMogul::VERSION).to eq("1.1.5")
  end
end
