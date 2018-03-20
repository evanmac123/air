require 'rails_helper'

RSpec.describe BoardCopierJob, type: :job do
  describe ".perform" do
    it "calls BoardCopier" do
      board = :board
      template = :template

      BoardCopier.expects(:call).with(board, template)

      BoardCopierJob.perform_now(board, template)
    end
  end
end
