module Tile::TileQuestionTypes
  # NOTE These question type constants are being migrated to the frontend. Evantually, we should remove this module.

  # Question Types
  ACTION = "Action".freeze
  QUIZ   = "Quiz".freeze
  SURVEY = "Survey".freeze

  # Question Subtypes
  TAKE_ACTION           = "Take Action".parameterize("_").freeze
  READ_TILE             = "Read Tile".parameterize("_").freeze
  READ_ARTICLE          = "Read Article".parameterize("_").freeze
  SHARE_ON_SOCIAL_MEDIA = "Share On Social Media".parameterize("_").freeze
  VISIT_WEB_SITE        = "Visit Web Site".parameterize("_").freeze
  WATCH_VIDEO           = "Watch Video".parameterize("_").freeze
  CUSTOM                = "Custom...".parameterize("_").freeze
  TRUE_FALSE            = "True / False".parameterize("_").freeze
  MULTIPLE_CHOICE       = "Multiple Choice".parameterize("_").freeze
  RSVP_TO_EVENT         = "RSVP to event".parameterize("_").freeze
  INVITE_SPOUSE         = "Invite Spouse".parameterize("_").freeze
  CHANGE_EMAIL          = "Change Email".parameterize("_").freeze
end
