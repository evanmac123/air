# frozen_string_literal: true

module ExploreConcern
  def explore_email_clicked_ping(user:, email_type:, email_version:)
    properties = {
      email_type: email_type,
      email_version: email_version,
    }

    ping("Email clicked", properties, user)
  end
end
