# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180411202822) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "btree_gin"
  enable_extension "btree_gist"
  enable_extension "pg_stat_statements"
  enable_extension "pg_trgm"

  create_table "acts", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "text",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rule_id"
    t.integer  "inherent_points"
    t.integer  "demo_id"
    t.integer  "referring_user_id"
    t.string   "creation_channel",  limit: 255, default: "",    null: false
    t.boolean  "hidden",                        default: false, null: false
    t.string   "privacy_level",     limit: 255
    t.integer  "rule_value_id"
    t.string   "user_type",         limit: 255
  end

  add_index "acts", ["demo_id"], name: "index_acts_on_demo_id", using: :btree
  add_index "acts", ["hidden", "demo_id"], name: "index_acts_on_hidden_and_demo_id", using: :btree
  add_index "acts", ["hidden"], name: "index_acts_on_hidden", using: :btree
  add_index "acts", ["privacy_level"], name: "index_acts_on_privacy_level", using: :btree
  add_index "acts", ["referring_user_id"], name: "index_acts_on_referring_user_id", using: :btree
  add_index "acts", ["rule_id"], name: "index_acts_on_rule_id", using: :btree
  add_index "acts", ["rule_value_id"], name: "index_acts_on_rule_value_id", using: :btree
  add_index "acts", ["text"], name: "index_acts_on_text", using: :btree
  add_index "acts", ["user_id"], name: "index_acts_on_player_id", using: :btree
  add_index "acts", ["user_type"], name: "index_acts_on_user_type", using: :btree

  create_table "bad_message_replies", force: :cascade do |t|
    t.string   "body",           limit: 160
    t.integer  "bad_message_id"
    t.integer  "sender_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bad_message_replies", ["bad_message_id"], name: "index_bad_message_replies_on_bad_message_id", using: :btree
  add_index "bad_message_replies", ["sender_id"], name: "index_bad_message_replies_on_sender_id", using: :btree

  create_table "bad_messages", force: :cascade do |t|
    t.string   "phone_number",    limit: 255
    t.text     "body"
    t.datetime "received_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_new",                      default: true
    t.boolean  "on_watch_list",               default: false
    t.integer  "reply_count",                 default: 0
    t.string   "automated_reply", limit: 160, default: "",    null: false
  end

  add_index "bad_messages", ["phone_number"], name: "index_bad_messages_on_phone_number", using: :btree

  create_table "bad_words", force: :cascade do |t|
    t.string   "value",      limit: 255, default: "", null: false
    t.integer  "demo_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bad_words", ["demo_id"], name: "index_bad_words_on_demo_id", using: :btree
  add_index "bad_words", ["value"], name: "index_bad_words_on_value", using: :btree

  create_table "balances", force: :cascade do |t|
    t.integer  "amount",     default: 0, null: false
    t.integer  "demo_id",                null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "balances", ["demo_id"], name: "index_balances_on_demo_id", using: :btree

  create_table "billing_informations", force: :cascade do |t|
    t.string   "expiration_month", limit: 255, default: "", null: false
    t.string   "expiration_year",  limit: 255, default: "", null: false
    t.string   "last_4",           limit: 255, default: "", null: false
    t.string   "customer_token",   limit: 255, default: "", null: false
    t.string   "card_token",       limit: 255, default: "", null: false
    t.string   "issuer",           limit: 255, default: "", null: false
    t.integer  "user_id"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  add_index "billing_informations", ["user_id"], name: "index_billing_informations_on_user_id", using: :btree

  create_table "billings", force: :cascade do |t|
    t.decimal  "amount"
    t.date     "posted"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "contract_id"
    t.integer  "organization_id"
  end

  create_table "board_health_reports", force: :cascade do |t|
    t.integer  "demo_id"
    t.integer  "tiles_copied_count"
    t.integer  "user_count"
    t.decimal  "activated_user_percent"
    t.integer  "tiles_posted_count"
    t.decimal  "tile_completion_average"
    t.decimal  "tile_completion_min"
    t.decimal  "tile_completion_max"
    t.decimal  "tile_view_average"
    t.decimal  "tile_view_max"
    t.decimal  "tile_view_min"
    t.decimal  "latest_tile_completion_rate"
    t.decimal  "latest_tile_view_rate"
    t.integer  "days_since_tile_posted"
    t.date     "from_date"
    t.date     "to_date"
    t.integer  "period_cd",                   default: 0
    t.integer  "health_score"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "board_health_reports", ["demo_id"], name: "index_board_health_reports_on_demo_id", using: :btree

  create_table "board_memberships", force: :cascade do |t|
    t.boolean  "is_current",                       default: true
    t.boolean  "is_client_admin",                  default: false
    t.integer  "points",                           default: 0
    t.integer  "tickets",                          default: 0
    t.integer  "ticket_threshold_base",            default: 0
    t.integer  "location_id"
    t.integer  "demo_id"
    t.integer  "user_id"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.boolean  "not_show_onboarding",              default: false
    t.boolean  "digest_muted",                     default: false
    t.boolean  "followup_muted",                   default: false
    t.boolean  "send_weekly_activity_report",      default: true
    t.boolean  "allowed_to_make_tile_suggestions", default: false, null: false
    t.datetime "joined_board_at"
    t.integer  "notification_pref_cd",             default: 0
  end

  add_index "board_memberships", ["demo_id"], name: "index_board_memberships_on_demo_id", using: :btree
  add_index "board_memberships", ["user_id"], name: "index_board_memberships_on_user_id", using: :btree

  create_table "bonus_thresholds", force: :cascade do |t|
    t.integer  "min_points", null: false
    t.integer  "max_points", null: false
    t.integer  "award",      null: false
    t.integer  "demo_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bonus_thresholds", ["demo_id"], name: "index_bonus_thresholds_on_demo_id", using: :btree
  add_index "bonus_thresholds", ["max_points"], name: "index_bonus_thresholds_on_max_points", using: :btree
  add_index "bonus_thresholds", ["min_points"], name: "index_bonus_thresholds_on_min_points", using: :btree

  create_table "bonus_thresholds_users", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "bonus_threshold_id"
  end

  add_index "bonus_thresholds_users", ["bonus_threshold_id"], name: "index_bonus_thresholds_users_on_bonus_threshold_id", using: :btree
  add_index "bonus_thresholds_users", ["user_id"], name: "index_bonus_thresholds_users_on_user_id", using: :btree

  create_table "campaigns", force: :cascade do |t|
    t.integer  "demo_id"
    t.text     "description"
    t.string   "name",                  limit: 255
    t.boolean  "active",                            default: false
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.string   "slug",                  limit: 255
    t.boolean  "ongoing",                           default: false
    t.string   "icon_link"
    t.boolean  "private_explore",                   default: false
    t.boolean  "public_explore",                    default: false
    t.string   "color"
    t.integer  "population_segment_id"
  end

  add_index "campaigns", ["demo_id"], name: "index_campaigns_on_demo_id", using: :btree
  add_index "campaigns", ["population_segment_id"], name: "index_campaigns_on_population_segment_id", using: :btree
  add_index "campaigns", ["slug"], name: "index_campaigns_on_slug", using: :btree

  create_table "case_studies", force: :cascade do |t|
    t.string   "client_name",              limit: 255
    t.text     "description"
    t.string   "slug",                     limit: 255
    t.string   "cover_image_file_name",    limit: 255
    t.string   "cover_image_content_type", limit: 255
    t.integer  "cover_image_file_size"
    t.datetime "cover_image_updated_at"
    t.string   "logo_file_name",           limit: 255
    t.string   "logo_content_type",        limit: 255
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "pdf_file_name",            limit: 255
    t.string   "pdf_content_type",         limit: 255
    t.integer  "pdf_file_size"
    t.datetime "pdf_updated_at"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.string   "non_pdf_url",              limit: 255
    t.text     "quote"
    t.text     "quote_cite"
    t.text     "quote_cite_title"
    t.integer  "position",                             default: 0
  end

  create_table "channels", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "slug",               limit: 255
    t.boolean  "active"
    t.text     "description"
    t.string   "image_header",       limit: 255
    t.integer  "rank",                           default: 0
  end

  add_index "channels", ["slug"], name: "index_channels_on_slug", using: :btree

  create_table "characteristics", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.string   "description",    limit: 255
    t.text     "allowed_values"
    t.integer  "demo_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "datatype",       limit: 255
  end

  add_index "characteristics", ["demo_id"], name: "index_characteristics_on_demo_id", using: :btree

  create_table "cheers", force: :cascade do |t|
    t.string   "body",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "claim_attempt_histories", force: :cascade do |t|
    t.string   "from",              limit: 255, default: "", null: false
    t.text     "claim_information"
    t.integer  "claim_state_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "demo_id"
  end

  add_index "claim_attempt_histories", ["demo_id"], name: "index_claim_attempt_histories_on_demo_id", using: :btree
  add_index "claim_attempt_histories", ["from"], name: "index_claim_attempt_histories_on_from", using: :btree

  create_table "claim_state_machines", force: :cascade do |t|
    t.text     "states"
    t.integer  "demo_id"
    t.integer  "start_state_id", default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "claim_state_machines", ["demo_id"], name: "index_claim_state_machines_on_demo_id", using: :btree

  create_table "contracts", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.integer  "organization_id"
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "mrr"
    t.integer  "arr"
    t.integer  "amt_booked"
    t.date     "date_booked"
    t.integer  "term"
    t.string   "plan",               limit: 255
    t.integer  "max_users"
    t.text     "notes"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.integer  "parent_contract_id"
    t.boolean  "is_actual",                      default: true
    t.boolean  "auto_renew",                     default: true
    t.string   "cycle",              limit: 255
    t.boolean  "in_collection",                  default: false
    t.date     "delinquency_date"
    t.date     "renewed_on"
  end

  add_index "contracts", ["organization_id"], name: "index_contracts_on_organization_id", using: :btree

  create_table "cust_success_kpis", force: :cascade do |t|
    t.integer  "paid_net_promoter_score"
    t.integer  "paid_net_promoter_score_response_count"
    t.integer  "total_paid_orgs"
    t.integer  "unique_org_with_activity_sessions"
    t.integer  "total_paid_client_admins"
    t.integer  "unique_client_admin_with_activity_sessions"
    t.integer  "total_paid_client_admin_activity_sessions"
    t.integer  "unique_orgs_that_copied_tiles"
    t.integer  "total_tiles_copied"
    t.integer  "orgs_that_posted_tiles"
    t.integer  "total_tiles_posted"
    t.float    "activity_sessions_per_client_admin"
    t.float    "average_tiles_copied_per_org_that_copied"
    t.float    "average_tiles_posted_per_organization_that_posted"
    t.float    "average_tile_creation_speed"
    t.float    "percent_engaged_organizations"
    t.float    "percent_engaged_client_admin"
    t.float    "percent_orgs_that_copied_tiles"
    t.float    "percent_of_orgs_that_posted_tiles"
    t.float    "percent_joined_current"
    t.float    "percent_joined_30_days"
    t.float    "percent_joined_60_days"
    t.float    "percent_joined_120_days"
    t.float    "percent_retained_post_activation_30_days"
    t.float    "percent_retained_post_activation_60_days"
    t.float    "percent_retained_post_activation_120_days"
    t.float    "average_tile_creation_time"
    t.datetime "created_at",                                                                      null: false
    t.datetime "updated_at",                                                                      null: false
    t.date     "report_date"
    t.date     "from_date"
    t.date     "to_date"
    t.date     "weekending_date"
    t.float    "percent_paid_orgs_view_tile_in_explore"
    t.integer  "paid_orgs_visited_explore"
    t.integer  "total_tiles_viewed_in_explore_by_paid_orgs"
    t.integer  "paid_client_admins_who_viewed_tiles_in_explore"
    t.float    "tiles_viewed_per_paid_client_admin"
    t.integer  "tiles_created_from_scratch"
    t.integer  "total_tiles_added_by_paid_client_admin"
    t.integer  "total_tiles_added_from_copy_by_paid_client_admin"
    t.integer  "total_tiles_added_from_scratch_by_paid_client_admin"
    t.float    "percent_of_added_tiles_from_copy"
    t.float    "percent_of_added_tiles_from_scratch"
    t.integer  "unique_orgs_that_added_tiles"
    t.float    "percent_orgs_that_added_tiles"
    t.integer  "orgs_that_created_tiles_from_scratch"
    t.float    "average_tiles_created_from_scratch_per_org_that_created"
    t.string   "interval",                                                limit: 255
    t.integer  "unique_orgs_that_viewed_tiles_in_explore"
    t.integer  "tiles_with_image_search",                                             default: 0
    t.integer  "tiles_with_image_upload",                                             default: 0
    t.integer  "tiles_with_video_upload",                                             default: 0
    t.decimal  "tile_completion_rate"
    t.decimal  "tile_view_rate"
    t.integer  "tiles_delivered_count"
  end

  create_table "custom_color_palettes", force: :cascade do |t|
    t.integer  "demo_id"
    t.integer  "company_id"
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.boolean  "enabled"
    t.boolean  "enable_reset"
    t.string   "content_background_reset",                 limit: 255
    t.string   "tile_progress_background_reset",           limit: 255
    t.string   "tile_progress_all_tiles_text_reset",       limit: 255
    t.string   "tile_progress_completed_tiles_text_reset", limit: 255
    t.string   "primary_color",                            limit: 255
    t.string   "static_text_color",                        limit: 255
  end

  add_index "custom_color_palettes", ["demo_id"], name: "index_custom_color_palettes_on_demo_id", using: :btree

  create_table "custom_invitation_emails", force: :cascade do |t|
    t.text     "custom_html_text"
    t.text     "custom_plain_text"
    t.text     "custom_subject"
    t.text     "custom_subject_with_referrer"
    t.integer  "demo_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "custom_invitation_emails", ["demo_id"], name: "index_custom_invitation_emails_on_demo_id", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",               default: 0
    t.integer  "attempts",               default: 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "queue",      limit: 255
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "demo_requests", force: :cascade do |t|
    t.string   "email",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "demos", force: :cascade do |t|
    t.string   "name",                                  limit: 255, default: "",                           null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "seed_points",                                       default: 0
    t.string   "custom_welcome_message",                limit: 160
    t.datetime "ends_at"
    t.string   "followup_welcome_message",              limit: 160, default: "",                           null: false
    t.integer  "followup_welcome_message_delay",                    default: 20
    t.integer  "credit_game_referrer_threshold",                    default: 100000
    t.integer  "game_referrer_bonus",                               default: 5
    t.boolean  "use_standard_playbook",                             default: true,                         null: false
    t.datetime "begins_at"
    t.string   "phone_number",                          limit: 255
    t.string   "prize",                                 limit: 255, default: "",                           null: false
    t.string   "help_message",                          limit: 255, default: "",                           null: false
    t.string   "email",                                 limit: 255
    t.string   "unrecognized_user_message",             limit: 255
    t.string   "act_too_early_message",                 limit: 255, default: "",                           null: false
    t.string   "act_too_late_message",                  limit: 255, default: "",                           null: false
    t.integer  "referred_credit_bonus",                             default: 2
    t.string   "survey_answer_activity_message",        limit: 255, default: "",                           null: false
    t.string   "login_announcement",                    limit: 500
    t.datetime "total_user_rankings_last_updated_at"
    t.datetime "average_user_rankings_last_updated_at"
    t.integer  "mute_notice_threshold"
    t.string   "sponsor",                               limit: 255
    t.string   "example_tooltip",                       limit: 255
    t.string   "example_tutorial",                      limit: 255
    t.integer  "ticket_threshold",                                  default: 20
    t.string   "client_name",                           limit: 255, default: "",                           null: false
    t.string   "custom_reply_email_name",               limit: 255
    t.string   "custom_already_claimed_message",        limit: 255
    t.boolean  "use_post_act_summaries",                            default: true
    t.string   "custom_support_reply",                  limit: 255
    t.text     "internal_domains"
    t.boolean  "show_invite_modal_when_game_closed",                default: false
    t.datetime "tile_digest_email_sent_at"
    t.string   "tutorial_type",                         limit: 255, default: "multiple_choice"
    t.boolean  "unclaimed_users_also_get_digest",                   default: true
    t.string   "public_slug",                           limit: 255
    t.boolean  "is_public",                                         default: true
    t.boolean  "upload_in_progress"
    t.datetime "users_last_loaded"
    t.boolean  "turn_off_admin_onboarding",                         default: false
    t.boolean  "is_paid",                                           default: false
    t.datetime "tile_last_posted_at"
    t.boolean  "use_location_in_conversion",                        default: false
    t.text     "persistent_message",                                default: ""
    t.string   "logo_file_name",                        limit: 255
    t.string   "logo_content_type",                     limit: 255
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.boolean  "allow_raw_in_persistent_message",                   default: false
    t.boolean  "is_parent",                                         default: false,                        null: false
    t.boolean  "everyone_can_make_tile_suggestions",                default: false,                        null: false
    t.text     "cover_message",                                     default: "",                           null: false
    t.string   "cover_image_file_name",                 limit: 255
    t.string   "cover_image_content_type",              limit: 255
    t.integer  "cover_image_file_size"
    t.datetime "cover_image_updated_at"
    t.boolean  "explore_disabled",                                  default: true
    t.integer  "dependent_board_id"
    t.boolean  "dependent_board_enabled",                           default: false
    t.string   "dependent_board_email_subject",         limit: 255
    t.text     "dependent_board_email_body"
    t.boolean  "alt_subject_enabled",                               default: false
    t.boolean  "allow_embed_video",                                 default: true
    t.integer  "organization_id"
    t.date     "launch_date"
    t.boolean  "guest_user_conversion_modal",                       default: true
    t.integer  "users_count"
    t.boolean  "marked_for_deletion",                               default: false
    t.integer  "customer_status_cd",                                default: 0
    t.integer  "current_health_score"
    t.boolean  "hide_social",                                       default: false
    t.string   "timezone",                              limit: 255, default: "Eastern Time (US & Canada)"
    t.boolean  "allow_unsubscribes",                                default: false
  end

  add_index "demos", ["dependent_board_id"], name: "index_demos_on_dependent_board_id", using: :btree
  add_index "demos", ["marked_for_deletion"], name: "index_demos_on_marked_for_deletion", using: :btree
  add_index "demos", ["organization_id"], name: "index_demos_on_organization_id", using: :btree
  add_index "demos", ["public_slug"], name: "index_demos_on_public_slug", using: :btree

  create_table "email_commands", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "status",        limit: 255
    t.string   "email_to",      limit: 255
    t.string   "email_from",    limit: 255
    t.string   "email_subject", limit: 255
    t.text     "email_plain"
    t.text     "clean_body"
    t.string   "response",      limit: 255
    t.datetime "response_sent"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "clean_subject"
  end

  add_index "email_commands", ["user_id"], name: "index_email_commands_on_user_id", using: :btree

  create_table "email_info_requests", force: :cascade do |t|
    t.string   "email",      limit: 255, default: "(email not entered)"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",       limit: 255, default: "(name not entered)"
    t.text     "comment",                default: ""
    t.string   "phone",      limit: 255
    t.string   "role",       limit: 255
    t.string   "size",       limit: 255
    t.string   "company",    limit: 255
    t.string   "source",     limit: 255
  end

  create_table "explore_digests", force: :cascade do |t|
    t.boolean  "approved",     default: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "delivered",    default: false
    t.datetime "delivered_at"
  end

  create_table "follow_up_digest_emails", force: :cascade do |t|
    t.date     "send_on"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "tiles_digest_id"
    t.text     "subject"
    t.boolean  "sent",            default: false
  end

  add_index "follow_up_digest_emails", ["tiles_digest_id"], name: "index_follow_up_digest_emails_on_tiles_digest_id", using: :btree

  create_table "former_friendships", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "former_friendships", ["friend_id"], name: "index_former_friendships_on_friend_id", using: :btree
  add_index "former_friendships", ["user_id"], name: "index_former_friendships_on_user_id", using: :btree

  create_table "friendships", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",         limit: 255, default: "pending", null: false
    t.integer  "request_index"
  end

  add_index "friendships", ["friend_id"], name: "index_friendships_on_friend_id", using: :btree
  add_index "friendships", ["request_index"], name: "index_friendships_on_request_index", using: :btree
  add_index "friendships", ["state", "user_id"], name: "index_friendships_on_state_and_user_id", using: :btree

  create_table "game_creation_requests", force: :cascade do |t|
    t.string   "customer_name",  limit: 255, default: "", null: false
    t.string   "customer_email", limit: 255, default: "", null: false
    t.string   "company_name",   limit: 255, default: "", null: false
    t.text     "interests",                  default: "", null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  create_table "goal_completions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "goal_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "goal_completions", ["goal_id"], name: "index_goal_completions_on_goal_id", using: :btree
  add_index "goal_completions", ["user_id"], name: "index_goal_completions_on_user_id", using: :btree

  create_table "goals", force: :cascade do |t|
    t.string   "name",                limit: 255, default: "", null: false
    t.integer  "demo_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "achievement_text",    limit: 255, default: "", null: false
    t.string   "completion_sms_text", limit: 255, default: "", null: false
  end

  add_index "goals", ["demo_id"], name: "index_goals_on_demo_id", using: :btree

  create_table "guest_users", force: :cascade do |t|
    t.integer  "points",                               default: 0
    t.integer  "tickets",                              default: 0
    t.integer  "ticket_threshold_base",                default: 0
    t.integer  "demo_id"
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.integer  "converted_user_id"
    t.boolean  "get_started_lightbox_displayed"
    t.datetime "last_acted_at"
    t.datetime "last_session_activity_at"
    t.boolean  "seeing_marketing_page_for_first_time", default: true
    t.boolean  "onboarding_seen",                      default: false
  end

  add_index "guest_users", ["demo_id"], name: "index_guest_users_on_demo_id", using: :btree

  create_table "image_containers", force: :cascade do |t|
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "incoming_sms", force: :cascade do |t|
    t.string   "from",       limit: 255
    t.string   "body",       limit: 255
    t.string   "twilio_sid", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invoice_transactions", force: :cascade do |t|
    t.integer  "invoice_id"
    t.integer  "type_cd",                      default: 0
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "result_cd",                    default: 0
    t.datetime "paid_date"
    t.string   "chart_mogul_uuid", limit: 255
  end

  add_index "invoice_transactions", ["invoice_id"], name: "index_invoice_transactions_on_invoice_id", using: :btree

  create_table "invoices", force: :cascade do |t|
    t.integer  "subscription_id"
    t.datetime "due_date"
    t.integer  "type_cd",              default: 0
    t.datetime "service_period_start"
    t.datetime "service_period_end"
    t.integer  "amount_in_cents",      default: 0
    t.text     "description"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.text     "chart_mogul_uuid"
  end

  add_index "invoices", ["subscription_id"], name: "index_invoices_on_subscription_id", using: :btree

  create_table "keys", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "keys", ["name"], name: "index_keys_on_name", using: :btree

  create_table "labels", force: :cascade do |t|
    t.integer  "rule_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "labels", ["rule_id", "tag_id"], name: "index_labels_on_rule_id_and_tag_id", using: :btree

  create_table "lead_contacts", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "email",             limit: 255
    t.string   "name",              limit: 255
    t.string   "phone",             limit: 255
    t.string   "role",              limit: 255
    t.string   "status",            limit: 255
    t.string   "source",            limit: 255
    t.string   "organization_name", limit: 255
    t.string   "organization_size", limit: 255
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "organization_id"
  end

  add_index "lead_contacts", ["email"], name: "index_lead_contacts_on_email", unique: true, using: :btree
  add_index "lead_contacts", ["organization_id"], name: "index_lead_contacts_on_organization_id", using: :btree
  add_index "lead_contacts", ["status"], name: "index_lead_contacts_on_status", using: :btree
  add_index "lead_contacts", ["user_id"], name: "index_lead_contacts_on_user_id", using: :btree

  create_table "levels", force: :cascade do |t|
    t.string   "name",              limit: 255, default: "", null: false
    t.integer  "threshold",                                  null: false
    t.integer  "demo_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "index_within_demo"
  end

  add_index "levels", ["demo_id"], name: "index_levels_on_demo_id", using: :btree
  add_index "levels", ["threshold"], name: "index_levels_on_threshold", using: :btree

  create_table "levels_users", id: false, force: :cascade do |t|
    t.integer "level_id"
    t.integer "user_id"
  end

  add_index "levels_users", ["level_id"], name: "index_levels_users_on_level_id", using: :btree
  add_index "levels_users", ["user_id"], name: "index_levels_users_on_user_id", using: :btree

  create_table "locations", force: :cascade do |t|
    t.string   "name",            limit: 255, default: "", null: false
    t.integer  "demo_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "normalized_name", limit: 255
  end

  add_index "locations", ["demo_id"], name: "index_locations_on_demo_id", using: :btree
  add_index "locations", ["name"], name: "location_name_trigram", using: :gin
  add_index "locations", ["normalized_name"], name: "location_normalized_name_trigram", using: :gin

  create_table "metrics", force: :cascade do |t|
    t.integer  "starting_customers"
    t.integer  "added_customers"
    t.integer  "churned_customers"
    t.decimal  "starting_mrr"
    t.decimal  "added_mrr"
    t.decimal  "new_cust_mrr"
    t.decimal  "upgrade_mrr"
    t.decimal  "possible_churn_mrr"
    t.decimal  "churned_mrr"
    t.float    "percent_churned_mrr"
    t.float    "net_churned_mrr"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.decimal  "amt_booked"
    t.string   "interval",                  limit: 255
    t.decimal  "downgrade_mrr"
    t.decimal  "churned_customer_mrr"
    t.decimal  "net_changed_mrr"
    t.integer  "net_change_customers"
    t.integer  "current_customers"
    t.float    "percent_churned_customers"
    t.decimal  "current_mrr"
    t.integer  "cust_churned"
    t.integer  "possible_churn_customers"
    t.decimal  "added_customer_amt_booked"
    t.decimal  "renewal_amt_booked"
    t.decimal  "upgrade_amt_booked"
    t.date     "from_date"
    t.date     "to_date"
  end

  add_index "metrics", ["from_date"], name: "index_metrics_on_from_date", using: :btree
  add_index "metrics", ["interval"], name: "index_metrics_on_interval", using: :btree
  add_index "metrics", ["to_date"], name: "index_metrics_on_to_date", using: :btree

  create_table "more_info_requests", force: :cascade do |t|
    t.string   "phone_number", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "command",      limit: 255
    t.integer  "user_id"
  end

  add_index "more_info_requests", ["user_id"], name: "index_more_info_requests_on_user_id", using: :btree

  create_table "onboardings", force: :cascade do |t|
    t.integer  "organization_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "demo_id"
    t.string   "topic_name",      limit: 255
  end

  add_index "onboardings", ["demo_id"], name: "index_onboardings_on_demo_id", using: :btree
  add_index "onboardings", ["organization_id"], name: "index_onboardings_on_organization_id", using: :btree

  create_table "organizations", force: :cascade do |t|
    t.string   "name",                  limit: 255
    t.integer  "num_employees"
    t.boolean  "churned"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.boolean  "is_hrm",                            default: false
    t.string   "slug",                  limit: 255
    t.boolean  "internal",                          default: false
    t.integer  "demos_count",                       default: 0,     null: false
    t.string   "logo_file_name",        limit: 255
    t.string   "logo_content_type",     limit: 255
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.boolean  "featured"
    t.text     "chart_mogul_uuid"
    t.string   "email",                 limit: 255
    t.string   "zip_code",              limit: 255
    t.date     "free_trial_started_at"
    t.integer  "company_size_cd",                   default: 0
  end

  add_index "organizations", ["name"], name: "index_organizations_on_name", using: :btree

  create_table "outgoing_sms", force: :cascade do |t|
    t.string   "body",       limit: 255
    t.string   "to",         limit: 255
    t.integer  "mate_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "outgoing_sms", ["mate_id"], name: "index_outgoing_sms_on_mate_id", using: :btree

  create_table "parent_board_users", force: :cascade do |t|
    t.integer  "points",                   default: 0
    t.integer  "tickets",                  default: 0
    t.integer  "ticket_threshold_base",    default: 0
    t.integer  "demo_id"
    t.integer  "user_id"
    t.datetime "last_acted_at"
    t.datetime "last_session_activity_at"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  create_table "payments", force: :cascade do |t|
    t.text     "raw_stripe_charge"
    t.integer  "amount"
    t.integer  "user_id"
    t.integer  "demo_id"
    t.integer  "balance_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "payments", ["demo_id", "user_id"], name: "index_payments_on_demo_id_and_user_id", using: :btree

  create_table "peer_invitations", force: :cascade do |t|
    t.integer  "inviter_id"
    t.integer  "invitee_id"
    t.integer  "demo_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "invitee_type", limit: 255, default: "User"
  end

  add_index "peer_invitations", ["created_at"], name: "index_peer_invitations_on_created_at", using: :btree
  add_index "peer_invitations", ["demo_id"], name: "index_peer_invitations_on_demo_id", using: :btree
  add_index "peer_invitations", ["invitee_id"], name: "index_peer_invitations_on_invitee_id", using: :btree
  add_index "peer_invitations", ["inviter_id"], name: "index_peer_invitations_on_inviter_id", using: :btree

  create_table "population_segments", force: :cascade do |t|
    t.string   "name"
    t.integer  "demo_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "population_segments", ["demo_id"], name: "index_population_segments_on_demo_id", using: :btree

  create_table "potential_users", force: :cascade do |t|
    t.string   "email",            limit: 255
    t.string   "invitation_code",  limit: 255
    t.integer  "demo_id"
    t.integer  "game_referrer_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "primary_user_id"
  end

  create_table "prerequisites", force: :cascade do |t|
    t.integer "prerequisite_tile_id", null: false
    t.integer "tile_id",              null: false
  end

  add_index "prerequisites", ["prerequisite_tile_id"], name: "index_prerequisites_on_prerequisite_id", using: :btree
  add_index "prerequisites", ["tile_id"], name: "index_prerequisites_on_task_id", using: :btree

  create_table "product_metrics_reports", force: :cascade do |t|
    t.date     "from_date"
    t.date     "to_date"
    t.integer  "period_cd",                                   default: 0
    t.integer  "smb_tiles_delivered"
    t.decimal  "smb_overall_completion_rate"
    t.decimal  "smb_completion_rate_in_range"
    t.decimal  "smb_overall_view_rate"
    t.decimal  "smb_view_rate_in_range"
    t.decimal  "smb_percent_orgs_posted"
    t.decimal  "smb_percent_orgs_activity"
    t.decimal  "smb_percent_orgs_copied"
    t.integer  "enterprise_tiles_delivered"
    t.decimal  "enterprise_overall_completion_rate"
    t.decimal  "enterprise_completion_rate_in_range"
    t.decimal  "enterprise_overall_view_rate"
    t.decimal  "enterprise_view_rate_in_range"
    t.decimal  "enterprise_percent_orgs_posted"
    t.decimal  "enterprise_percent_orgs_activity"
    t.decimal  "enterprise_percent_orgs_copied"
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.decimal  "smb_digest_active_user_rate_in_range"
    t.decimal  "enterprise_digest_active_user_rate_in_range"
    t.decimal  "smb_mau_rate"
    t.decimal  "enterprise_mau_rate"
    t.decimal  "smb_mau_view_rate"
    t.decimal  "enterprise_mau_view_rate"
  end

  create_table "push_messages", force: :cascade do |t|
    t.text     "subject"
    t.text     "plain_text"
    t.text     "html_text"
    t.string   "sms_text",                    limit: 160
    t.string   "state",                       limit: 255, default: "scheduled"
    t.datetime "scheduled_for"
    t.text     "email_recipient_ids"
    t.text     "sms_recipient_ids"
    t.text     "segment_description"
    t.integer  "demo_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "respect_notification_method"
    t.string   "segment_query_columns",       limit: 255
    t.string   "segment_query_operators",     limit: 255
    t.string   "segment_query_values",        limit: 255
  end

  create_table "raffles", force: :cascade do |t|
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.text     "prizes"
    t.text     "other_info"
    t.string   "status",         limit: 255
    t.integer  "demo_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "delayed_job_id"
  end

  add_index "raffles", ["demo_id"], name: "index_raffles_on_demo_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.integer  "resource_id"
    t.string   "resource_type", limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "rule_values", force: :cascade do |t|
    t.string   "value",      limit: 255
    t.boolean  "is_primary",             default: false, null: false
    t.integer  "rule_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rule_values", ["is_primary"], name: "index_rule_values_on_is_primary", using: :btree
  add_index "rule_values", ["rule_id"], name: "index_rule_values_on_rule_id", using: :btree

  create_table "rules", force: :cascade do |t|
    t.integer  "points"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "reply",           limit: 255, default: "",   null: false
    t.string   "type",            limit: 255
    t.string   "description",     limit: 255
    t.integer  "alltime_limit"
    t.integer  "referral_points"
    t.boolean  "suggestible",                 default: true, null: false
    t.integer  "demo_id"
    t.integer  "goal_id"
    t.integer  "primary_tag_id"
  end

  add_index "rules", ["demo_id"], name: "index_rules_on_demo_id", using: :btree
  add_index "rules", ["goal_id", "primary_tag_id"], name: "index_rules_on_goal_id_and_primary_tag_id", using: :btree

  create_table "searchjoy_searches", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "search_type",      limit: 255
    t.string   "query",            limit: 255
    t.string   "normalized_query", limit: 255
    t.integer  "results_count"
    t.datetime "created_at"
    t.integer  "convertable_id"
    t.string   "convertable_type", limit: 255
    t.datetime "converted_at"
    t.integer  "demo_id"
    t.string   "user_email",       limit: 255
  end

  add_index "searchjoy_searches", ["convertable_id", "convertable_type"], name: "index_searchjoy_searches_on_convertable_id_and_convertable_type", using: :btree
  add_index "searchjoy_searches", ["created_at"], name: "index_searchjoy_searches_on_created_at", using: :btree
  add_index "searchjoy_searches", ["search_type", "created_at"], name: "index_searchjoy_searches_on_search_type_and_created_at", using: :btree
  add_index "searchjoy_searches", ["search_type", "normalized_query", "created_at"], name: "index_searchjoy_searches_on_search_type_and_normalized_query_an", using: :btree

  create_table "subscription_plans", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.integer  "interval_count",               default: 1
    t.integer  "interval_cd",                  default: 0
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.text     "chart_mogul_uuid"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "organization_id"
    t.integer  "subscription_plan_id"
    t.datetime "cancelled_at"
    t.string   "chart_mogul_uuid",     limit: 255
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.datetime "subscription_start"
  end

  add_index "subscriptions", ["organization_id"], name: "index_subscriptions_on_organization_id", using: :btree
  add_index "subscriptions", ["subscription_plan_id"], name: "index_subscriptions_on_subscription_plan_id", using: :btree

  create_table "suggestions", force: :cascade do |t|
    t.string   "value",      limit: 255, default: "", null: false
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "suggestions", ["user_id"], name: "index_suggestions_on_user_id", using: :btree

  create_table "supports", force: :cascade do |t|
    t.text     "body",       default: ""
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "survey_answers", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "survey_question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "survey_valid_answer_id"
  end

  add_index "survey_answers", ["survey_question_id"], name: "index_survey_answers_on_survey_question_id", using: :btree
  add_index "survey_answers", ["survey_valid_answer_id"], name: "index_survey_answers_on_survey_valid_answer_id", using: :btree
  add_index "survey_answers", ["user_id"], name: "index_survey_answers_on_user_id", using: :btree

  create_table "survey_prompts", force: :cascade do |t|
    t.datetime "send_time",                           null: false
    t.string   "text",       limit: 255, default: "", null: false
    t.integer  "survey_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "survey_prompts", ["survey_id"], name: "index_survey_prompts_on_survey_id", using: :btree

  create_table "survey_questions", force: :cascade do |t|
    t.string   "text",       limit: 255, default: "", null: false
    t.integer  "index",                               null: false
    t.integer  "survey_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "points"
  end

  add_index "survey_questions", ["index"], name: "index_survey_questions_on_index", using: :btree
  add_index "survey_questions", ["survey_id"], name: "index_survey_questions_on_survey_id", using: :btree

  create_table "survey_valid_answers", force: :cascade do |t|
    t.string   "value",              limit: 255, default: "", null: false
    t.integer  "survey_question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "survey_valid_answers", ["survey_question_id"], name: "index_survey_valid_answers_on_survey_question_id", using: :btree
  add_index "survey_valid_answers", ["value"], name: "index_survey_valid_answers_on_value", using: :btree

  create_table "surveys", force: :cascade do |t|
    t.string   "name",       limit: 255, default: "", null: false
    t.integer  "demo_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "open_at",                             null: false
    t.datetime "close_at"
  end

  add_index "surveys", ["close_at"], name: "index_surveys_on_close_at", using: :btree
  add_index "surveys", ["demo_id"], name: "index_surveys_on_demo_id", using: :btree
  add_index "surveys", ["open_at"], name: "index_surveys_on_open_at", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type", limit: 255
    t.integer  "tagger_id"
    t.string   "tagger_type",   limit: 255
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name",           limit: 255
    t.integer "taggings_count",             default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "tile_completions", force: :cascade do |t|
    t.integer  "tile_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "user_type",                 limit: 255
    t.integer  "answer_index"
    t.boolean  "not_show_in_tile_progress",             default: false
    t.text     "free_form_response"
    t.text     "custom_form"
  end

  add_index "tile_completions", ["created_at"], name: "index_tile_completions_on_created_at", using: :btree
  add_index "tile_completions", ["tile_id", "user_id", "user_type"], name: "index_tile_completions_on_tile_id_and_user_id_and_user_type", using: :btree
  add_index "tile_completions", ["tile_id", "user_type"], name: "index_tile_completions_on_tile_id_and_user_type", using: :btree
  add_index "tile_completions", ["user_id"], name: "index_task_suggestions_on_user_id", using: :btree
  add_index "tile_completions", ["user_type"], name: "index_tile_completions_on_user_type", using: :btree

  create_table "tile_features", force: :cascade do |t|
    t.integer  "rank"
    t.string   "name",                      limit: 255
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.boolean  "active"
    t.integer  "channel_id"
    t.string   "slug",                      limit: 255
    t.boolean  "show_related_content_link",             default: false
  end

  add_index "tile_features", ["channel_id"], name: "index_tile_features_on_channel_id", using: :btree

  create_table "tile_images", force: :cascade do |t|
    t.string   "image_file_name",        limit: 255
    t.string   "image_content_type",     limit: 255
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "thumbnail_file_name",    limit: 255
    t.string   "thumbnail_content_type", limit: 255
    t.integer  "thumbnail_file_size"
    t.datetime "thumbnail_updated_at"
    t.boolean  "image_processing"
    t.boolean  "thumbnail_processing"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "remote_media_url",       limit: 255
    t.text     "image_meta"
  end

  create_table "tile_media", force: :cascade do |t|
    t.integer  "tile_id"
    t.string   "document_file_name",    limit: 255
    t.string   "document_content_type", limit: 255
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.string   "remote_url",            limit: 255
    t.boolean  "processed"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "tile_media", ["tile_id"], name: "index_tile_media_on_tile_id", using: :btree

  create_table "tile_taggings", force: :cascade do |t|
    t.integer  "tile_id"
    t.integer  "tile_tag_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "tile_taggings", ["tile_id"], name: "index_tile_taggings_on_tile_id", using: :btree
  add_index "tile_taggings", ["tile_tag_id"], name: "index_tile_taggings_on_tile_tag_id", using: :btree

  create_table "tile_tags", force: :cascade do |t|
    t.string   "title",      limit: 255, default: ""
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "topic_id"
  end

  add_index "tile_tags", ["topic_id"], name: "index_tile_tags_on_topic_id", using: :btree

  create_table "tile_user_notifications", force: :cascade do |t|
    t.integer  "tile_id"
    t.integer  "creator_id"
    t.string   "subject",         limit: 255
    t.text     "message"
    t.integer  "scope_cd"
    t.datetime "delivered_at"
    t.integer  "recipient_count"
    t.datetime "send_at"
    t.integer  "delayed_job_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "answer_idx"
  end

  add_index "tile_user_notifications", ["tile_id"], name: "index_tile_user_notifications_on_tile_id", using: :btree

  create_table "tile_viewings", force: :cascade do |t|
    t.integer  "tile_id"
    t.integer  "user_id"
    t.string   "user_type",  limit: 255
    t.integer  "views",                  default: 1
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "tile_viewings", ["created_at"], name: "index_tile_viewings_on_created_at", using: :btree
  add_index "tile_viewings", ["tile_id", "user_id", "user_type"], name: "index_tile_viewings_on_tile_and_user", unique: true, using: :btree
  add_index "tile_viewings", ["tile_id", "user_type"], name: "index_tile_viewings_on_tile_id_and_user_type", using: :btree
  add_index "tile_viewings", ["user_id"], name: "index_tile_viewings_on_user_id", using: :btree

  create_table "tiles", force: :cascade do |t|
    t.integer  "demo_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "start_time"
    t.integer  "bonus_points",                        default: 0,     null: false
    t.datetime "end_time"
    t.integer  "position"
    t.boolean  "poly",                                default: false, null: false
    t.string   "image_file_name",         limit: 255
    t.string   "image_content_type",      limit: 255
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "headline",                limit: 255, default: "",    null: false
    t.string   "thumbnail_file_name",     limit: 255
    t.string   "thumbnail_content_type",  limit: 255
    t.integer  "thumbnail_file_size"
    t.datetime "thumbnail_updated_at"
    t.boolean  "require_images",                      default: true,  null: false
    t.text     "image_meta"
    t.text     "thumbnail_meta"
    t.text     "link_address",                        default: ""
    t.text     "supporting_content",                  default: ""
    t.text     "question",                            default: ""
    t.string   "status",                  limit: 255
    t.datetime "activated_at"
    t.datetime "archived_at"
    t.text     "multiple_choice_answers"
    t.integer  "correct_answer_index"
    t.integer  "points"
    t.boolean  "image_processing"
    t.boolean  "thumbnail_processing"
    t.integer  "creator_id"
    t.string   "question_type",           limit: 255
    t.string   "question_subtype",        limit: 255
    t.text     "image_credit"
    t.boolean  "is_public",                           default: false, null: false
    t.boolean  "is_copyable",                         default: false, null: false
    t.integer  "original_creator_id"
    t.datetime "original_created_at"
    t.boolean  "is_sharable",                         default: false, null: false
    t.integer  "tile_completions_count",              default: 0
    t.integer  "explore_page_priority"
    t.integer  "unique_viewings_count",               default: 0,     null: false
    t.integer  "total_viewings_count",                default: 0,     null: false
    t.integer  "user_tile_likes_count",               default: 0
    t.boolean  "user_created"
    t.text     "remote_media_url"
    t.string   "remote_media_type",       limit: 255
    t.boolean  "use_old_line_break_css",              default: false
    t.text     "embed_video",                         default: "",    null: false
    t.string   "media_source",            limit: 255
    t.integer  "creation_source_cd",                  default: 0
    t.integer  "copy_count",                          default: 0
    t.boolean  "allow_free_response",                 default: false
    t.boolean  "is_anonymous",                        default: false
    t.text     "file_attachments"
    t.date     "plan_date"
    t.integer  "campaign_id"
  end

  add_index "tiles", ["activated_at"], name: "index_tiles_on_activated_at", using: :btree
  add_index "tiles", ["archived_at"], name: "index_tiles_on_archived_at", using: :btree
  add_index "tiles", ["campaign_id"], name: "index_tiles_on_campaign_id", using: :btree
  add_index "tiles", ["created_at"], name: "index_tiles_on_created_at", using: :btree
  add_index "tiles", ["demo_id"], name: "index_tiles_on_demo_id", using: :btree
  add_index "tiles", ["is_copyable"], name: "index_tiles_on_is_copyable", using: :btree
  add_index "tiles", ["is_public"], name: "index_tiles_on_is_public", using: :btree
  add_index "tiles", ["status"], name: "index_tiles_on_status", using: :btree

  create_table "tiles_digest_automators", force: :cascade do |t|
    t.integer  "demo_id"
    t.datetime "deliver_date"
    t.integer  "day",                                 default: 1
    t.string   "time",                    limit: 255, default: "9"
    t.integer  "frequency_cd",                        default: 1
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.integer  "job_id"
    t.boolean  "has_follow_up",                       default: true
    t.boolean  "include_sms",                         default: false
    t.boolean  "include_unclaimed_users",             default: true
  end

  add_index "tiles_digest_automators", ["demo_id"], name: "index_tiles_digest_automators_on_demo_id", using: :btree

  create_table "tiles_digest_tiles", force: :cascade do |t|
    t.integer  "tile_id"
    t.integer  "tiles_digest_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "tiles_digest_tiles", ["tile_id"], name: "index_tiles_digest_tiles_on_tile_id", using: :btree
  add_index "tiles_digest_tiles", ["tiles_digest_id"], name: "index_tiles_digest_tiles_on_tiles_digest_id", using: :btree

  create_table "tiles_digests", force: :cascade do |t|
    t.integer  "demo_id"
    t.integer  "sender_id"
    t.datetime "cutoff_time"
    t.integer  "recipient_count",         default: 0
    t.text     "headline"
    t.text     "message"
    t.text     "subject"
    t.text     "alt_subject"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.boolean  "include_unclaimed_users"
    t.boolean  "delivered",               default: false
    t.boolean  "followup_delivered",      default: false
    t.datetime "sent_at"
    t.boolean  "include_sms",             default: false
  end

  add_index "tiles_digests", ["demo_id"], name: "index_tiles_digests_on_demo_id", using: :btree
  add_index "tiles_digests", ["sender_id"], name: "index_tiles_digests_on_sender_id", using: :btree

  create_table "timed_bonus", force: :cascade do |t|
    t.datetime "expires_at",                             null: false
    t.boolean  "fulfilled",              default: false, null: false
    t.integer  "points",                                 null: false
    t.string   "sms_text",   limit: 255, default: "",    null: false
    t.integer  "user_id"
    t.integer  "demo_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "timed_bonus", ["demo_id", "user_id"], name: "index_timed_bonus_on_demo_id_and_user_id", using: :btree

  create_table "topic_boards", force: :cascade do |t|
    t.integer  "demo_id"
    t.integer  "topic_id"
    t.boolean  "is_reference"
    t.boolean  "is_library"
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.boolean  "is_onboarding",                        default: false, null: false
    t.string   "cover_image_file_name",    limit: 255
    t.string   "cover_image_content_type", limit: 255
    t.integer  "cover_image_file_size"
    t.datetime "cover_image_updated_at"
  end

  create_table "topics", force: :cascade do |t|
    t.string   "name",                     limit: 255,                null: false
    t.string   "image",                    limit: 255
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.boolean  "is_explore",                           default: true, null: false
    t.string   "cover_image_file_name",    limit: 255
    t.string   "cover_image_content_type", limit: 255
    t.integer  "cover_image_file_size"
    t.datetime "cover_image_updated_at"
  end

  create_table "trigger_demographic_triggers", force: :cascade do |t|
    t.integer  "tile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "trigger_demographic_triggers", ["tile_id"], name: "index_trigger_demographic_triggers_on_task_id", using: :btree

  create_table "trigger_rule_triggers", force: :cascade do |t|
    t.integer  "rule_id"
    t.integer  "tile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "referrer_required", default: false, null: false
  end

  add_index "trigger_rule_triggers", ["referrer_required"], name: "index_trigger_rule_triggers_on_referrer_required", using: :btree
  add_index "trigger_rule_triggers", ["rule_id"], name: "index_trigger_rule_triggers_on_rule_id", using: :btree
  add_index "trigger_rule_triggers", ["tile_id"], name: "index_trigger_rule_triggers_on_task_id", using: :btree

  create_table "trigger_survey_triggers", force: :cascade do |t|
    t.integer  "survey_id"
    t.integer  "tile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "trigger_survey_triggers", ["survey_id"], name: "index_trigger_survey_triggers_on_survey_id", using: :btree
  add_index "trigger_survey_triggers", ["tile_id"], name: "index_trigger_survey_triggers_on_task_id", using: :btree

  create_table "tutorials", force: :cascade do |t|
    t.integer  "user_id",                      null: false
    t.datetime "ended_at"
    t.boolean  "completed",    default: false, null: false
    t.integer  "current_step", default: 0,     null: false
    t.integer  "friend_id"
    t.text     "first_act",    default: "",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tutorials", ["user_id"], name: "index_tutorials_on_user_id", using: :btree

  create_table "unsubscribes", force: :cascade do |t|
    t.integer  "user_id",                 null: false
    t.text     "reason",     default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "unsubscribes", ["user_id"], name: "index_unsubscribes_on_user_id", using: :btree

  create_table "user_in_raffle_infos", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "raffle_id"
    t.boolean  "start_showed",              default: false,  null: false
    t.boolean  "finish_showed",             default: false,  null: false
    t.boolean  "in_blacklist",              default: false,  null: false
    t.boolean  "is_winner",                 default: false,  null: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "user_type",     limit: 255, default: "User"
  end

  add_index "user_in_raffle_infos", ["user_id", "user_type", "raffle_id"], name: "user_in_raffle", unique: true, using: :btree

  create_table "user_intros", force: :cascade do |t|
    t.integer  "user_id"
    t.boolean  "explore_intro_seen",                    default: false
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.boolean  "explore_preview_copy_seen",             default: false
    t.boolean  "displayed_first_tile_hint",             default: false
    t.integer  "userable_id"
    t.string   "userable_type",             limit: 255
  end

  add_index "user_intros", ["user_id"], name: "index_user_intros_on_user_id", using: :btree

  create_table "user_onboardings", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "onboarding_id"
    t.integer  "state",                      default: 2
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "auth_hash",      limit: 255
    t.boolean  "demo_scheduled",             default: false, null: false
    t.boolean  "shared",                     default: false, null: false
    t.boolean  "completed",                  default: false, null: false
    t.string   "more_info",      limit: 255
  end

  add_index "user_onboardings", ["onboarding_id"], name: "index_user_onboardings_on_onboarding_id", using: :btree
  add_index "user_onboardings", ["user_id"], name: "index_user_onboardings_on_user_id", using: :btree

  create_table "user_settings_change_logs", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "email",       limit: 255, default: "", null: false
    t.string   "email_token", limit: 128
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "user_settings_change_logs", ["user_id"], name: "index_user_settings_change_logs_on_user_id", using: :btree

  create_table "user_tile_copies", force: :cascade do |t|
    t.integer  "tile_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "user_tile_copies", ["tile_id"], name: "index_user_tile_copies_on_tile_id", using: :btree
  add_index "user_tile_copies", ["user_id"], name: "index_user_tile_copies_on_user_id", using: :btree

  create_table "user_tile_likes", force: :cascade do |t|
    t.integer  "tile_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "user_tile_likes", ["tile_id", "user_id"], name: "index_user_tile_likes_on_tile_id_and_user_id", unique: true, using: :btree
  add_index "user_tile_likes", ["tile_id"], name: "index_user_tile_likes_on_tile_id", using: :btree
  add_index "user_tile_likes", ["user_id"], name: "index_user_tile_likes_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name",                             limit: 255, default: "",          null: false
    t.string   "email",                            limit: 255, default: "",          null: false
    t.boolean  "invited",                                      default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "invitation_code",                  limit: 255, default: "",          null: false
    t.string   "phone_number",                     limit: 255, default: "",          null: false
    t.integer  "points",                                       default: 0,           null: false
    t.string   "encrypted_password",               limit: 128
    t.string   "salt",                             limit: 128
    t.string   "remember_token",                   limit: 128
    t.string   "slug",                             limit: 255, default: "",          null: false
    t.string   "claim_code",                       limit: 255
    t.string   "confirmation_token",               limit: 128
    t.string   "sms_slug",                         limit: 255, default: "",          null: false
    t.string   "avatar_file_name",                 limit: 255
    t.string   "avatar_content_type",              limit: 255
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.datetime "accepted_invitation_at"
    t.integer  "game_referrer_id"
    t.boolean  "is_site_admin",                                default: false,       null: false
    t.string   "notification_method",              limit: 255, default: "email",     null: false
    t.integer  "location_id"
    t.string   "new_phone_number",                 limit: 255, default: "",          null: false
    t.string   "new_phone_validation",             limit: 255, default: "",          null: false
    t.date     "date_of_birth"
    t.string   "gender",                           limit: 255
    t.string   "invitation_method",                limit: 255, default: "",          null: false
    t.integer  "session_count",                                default: 0,           null: false
    t.string   "privacy_level",                    limit: 255, default: "connected", null: false
    t.datetime "last_muted_at"
    t.text     "characteristics"
    t.string   "overflow_email",                   limit: 255, default: ""
    t.integer  "tickets",                                      default: 0,           null: false
    t.string   "zip_code",                         limit: 255
    t.string   "employee_id",                      limit: 255
    t.integer  "spouse_id"
    t.datetime "last_acted_at"
    t.boolean  "is_client_admin",                              default: false
    t.integer  "ticket_threshold_base",                        default: 0
    t.boolean  "get_started_lightbox_displayed"
    t.integer  "original_guest_user_id"
    t.string   "cancel_account_token",             limit: 255
    t.datetime "last_session_activity_at"
    t.boolean  "has_own_tile_completed",                       default: false
    t.boolean  "has_own_tile_completed_displayed",             default: false
    t.integer  "has_own_tile_completed_id"
    t.string   "explore_token",                    limit: 255
    t.boolean  "is_test_user"
    t.string   "mixpanel_distinct_id",             limit: 255
    t.boolean  "send_weekly_activity_report",                  default: true
    t.boolean  "allowed_to_make_tile_suggestions",             default: false,       null: false
    t.boolean  "suggestion_box_intro_seen",                    default: false,       null: false
    t.boolean  "user_submitted_tile_intro_seen",               default: false,       null: false
    t.boolean  "manage_access_prompt_seen",                    default: false,       null: false
    t.integer  "primary_user_id"
    t.string   "official_email",                   limit: 255
    t.integer  "organization_id"
    t.boolean  "receives_sms",                                 default: true
    t.boolean  "receives_explore_email",                       default: true
    t.jsonb    "segments",                                     default: {}
    t.jsonb    "population_segments",                          default: {}
  end

  add_index "users", ["cancel_account_token"], name: "index_users_on_cancel_account_token", using: :btree
  add_index "users", ["claim_code"], name: "index_users_on_claim_code", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["email"], name: "user_email_trigram", using: :gin
  add_index "users", ["employee_id"], name: "index_users_on_employee_id", using: :btree
  add_index "users", ["explore_token"], name: "index_users_on_explore_token", using: :btree
  add_index "users", ["game_referrer_id"], name: "index_users_on_game_referrer_id", using: :btree
  add_index "users", ["invitation_code"], name: "index_users_on_invitation_code", using: :btree
  add_index "users", ["is_site_admin"], name: "index_users_on_is_site_admin", using: :btree
  add_index "users", ["location_id"], name: "index_users_on_location_id", using: :btree
  add_index "users", ["name"], name: "user_name_trigram", using: :gin
  add_index "users", ["official_email"], name: "index_users_on_official_email", using: :btree
  add_index "users", ["organization_id"], name: "index_users_on_organization_id", using: :btree
  add_index "users", ["overflow_email"], name: "index_users_on_overflow_email", using: :btree
  add_index "users", ["phone_number"], name: "index_users_on_phone_number", using: :btree
  add_index "users", ["population_segments"], name: "index_users_on_population_segments", using: :gin
  add_index "users", ["privacy_level"], name: "index_users_on_privacy_level", using: :btree
  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree
  add_index "users", ["segments"], name: "index_users_on_segments", using: :gin
  add_index "users", ["slug"], name: "index_users_on_slug", using: :btree
  add_index "users", ["slug"], name: "user_slug_trigram", using: :gin
  add_index "users", ["sms_slug"], name: "index_users_on_sms_slug", using: :btree
  add_index "users", ["spouse_id"], name: "index_users_on_spouse_id", using: :btree
  add_index "users", ["zip_code"], name: "index_users_on_zip_code", using: :btree

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

  add_foreign_key "campaigns", "population_segments"
  add_foreign_key "population_segments", "demos"
  add_foreign_key "tiles", "campaigns"
end
