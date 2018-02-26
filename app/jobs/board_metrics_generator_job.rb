# frozen_string_literal: true

class BoardMetricsGeneratorJob < ActiveJob::Base
  queue_as :default

  def perform(board:)
    BoardMetricsGenerator.call(board: board)
  end
end
