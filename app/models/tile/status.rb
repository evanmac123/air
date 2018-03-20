# frozen_string_literal: true

module Tile::Status
  extend ActiveSupport::Concern

  # TODO: Migrate to enum
  ACTIVE  = "active"
  ARCHIVE = "archive"
  DRAFT   = "draft"
  PLAN    = "plan"
  IGNORED = "ignored"
  USER_SUBMITTED = "user_submitted"
  STATUS = [ARCHIVE, ACTIVE, DRAFT, PLAN, USER_SUBMITTED, IGNORED].freeze

  included do
    STATUS.each do |status_name|
      scope status_name.to_sym, -> { where(status: status_name) }
    end

    scope :suggested, -> do
      where(status: [USER_SUBMITTED, IGNORED]).order(status: :desc)
    end
  end

  STATUS.each do |status_name|
    define_method(status_name + "?") do
      self.status == status_name
    end
  end
end
