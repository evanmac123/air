require 'rails_helper'

RSpec.describe BoardMetricsGeneratorJob, type: :job do
  describe ".perform" do
    it "calls BoardMetricsGenerator" do
      board = "Demo"
      BoardMetricsGenerator.expects(:call).with(board: board)

      BoardMetricsGeneratorJob.perform_later(board: board)
    end
  end
end
