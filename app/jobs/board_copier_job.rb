# frozen_string_literal: true

class BoardCopierJob < ActiveJob::Base
  queue_as :default

  def perform(board, template)
    BoardCopier.call(board, template)
  end
end
