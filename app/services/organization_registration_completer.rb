# frozen_string_literal: true

class OrganizationRegistrationCompleter
  def self.call(registration, creator)
    OrganizationRegistrationCompleter.new(registration, creator).perform
  end

  attr_reader :registration, :creator

  def initialize(registration, creator)
    @registration = registration
    @creator = creator
  end

  def perform
    copy_template_board
    creator.move_to_new_demo(board)
  end

  private

    def template_id
      registration.board_template_id
    end

    def board
      registration.board
    end

    def copy_template_board
      if template_id.present?
        template = Demo.find(template_id)
        BoardCopierJob.perform_later(board, template)
      end
    end
end
