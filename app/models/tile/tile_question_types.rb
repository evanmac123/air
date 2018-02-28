# frozen_string_literal: true

module Tile::TileQuestionTypes
  # NOTE These question type constants are being migrated to the frontend. Evantually, we should remove this module.

  # Question Types
  ACTION = "action"
  QUIZ   = "quiz"
  SURVEY = "survey"

  # Question Subtypes
  TAKE_ACTION           = "Take Action".parameterize("_")
  READ_TILE             = "Read Tile".parameterize("_")
  READ_ARTICLE          = "Read Article".parameterize("_")
  SHARE_ON_SOCIAL_MEDIA = "Share On Social Media".parameterize("_")
  VISIT_WEB_SITE        = "Visit Web Site".parameterize("_")
  WATCH_VIDEO           = "Watch Video".parameterize("_")
  CUSTOM                = "Custom...".parameterize("_")
  TRUE_FALSE            = "True / False".parameterize("_")
  MULTIPLE_CHOICE       = "Multiple Choice".parameterize("_")
  RSVP_TO_EVENT         = "RSVP to event".parameterize("_")
  INVITE_SPOUSE         = "Invite Spouse".parameterize("_")
  CHANGE_EMAIL          = "Change Email".parameterize("_")
end
