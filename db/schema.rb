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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20150604010815) do

  create_table "acts", :force => true do |t|
    t.integer  "user_id"
    t.string   "text"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.integer  "rule_id"
    t.integer  "inherent_points"
    t.integer  "demo_id"
    t.integer  "referring_user_id"
    t.string   "creation_channel",  :default => "",    :null => false
    t.boolean  "hidden",            :default => false, :null => false
    t.string   "privacy_level"
    t.integer  "rule_value_id"
    t.string   "user_type"
  end

  add_index "acts", ["demo_id"], :name => "index_acts_on_demo_id"
  add_index "acts", ["hidden", "demo_id"], :name => "index_acts_on_hidden_and_demo_id"
  add_index "acts", ["privacy_level"], :name => "index_acts_on_privacy_level"
  add_index "acts", ["referring_user_id"], :name => "index_acts_on_referring_user_id"
  add_index "acts", ["rule_id"], :name => "index_acts_on_rule_id"
  add_index "acts", ["rule_value_id"], :name => "index_acts_on_rule_value_id"
  add_index "acts", ["text"], :name => "index_acts_on_text"
  add_index "acts", ["user_id"], :name => "index_acts_on_player_id"
  add_index "acts", ["user_type"], :name => "index_acts_on_user_type"

  create_table "bad_message_replies", :force => true do |t|
    t.string   "body",           :limit => 160
    t.integer  "bad_message_id"
    t.integer  "sender_id"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "bad_message_replies", ["bad_message_id"], :name => "index_bad_message_replies_on_bad_message_id"
  add_index "bad_message_replies", ["sender_id"], :name => "index_bad_message_replies_on_sender_id"

  create_table "bad_messages", :force => true do |t|
    t.string   "phone_number"
    t.text     "body"
    t.datetime "received_at"
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
    t.boolean  "is_new",                         :default => true
    t.boolean  "on_watch_list",                  :default => false
    t.integer  "reply_count",                    :default => 0
    t.string   "automated_reply", :limit => 160, :default => "",    :null => false
  end

  add_index "bad_messages", ["phone_number"], :name => "index_bad_messages_on_phone_number"

  create_table "bad_words", :force => true do |t|
    t.string   "value",      :default => "", :null => false
    t.integer  "demo_id"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "bad_words", ["demo_id"], :name => "index_bad_words_on_demo_id"
  add_index "bad_words", ["value"], :name => "index_bad_words_on_value"

  create_table "balances", :force => true do |t|
    t.integer  "amount",     :default => 0, :null => false
    t.integer  "demo_id",                   :null => false
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "balances", ["demo_id"], :name => "index_balances_on_demo_id"

  create_table "billing_informations", :force => true do |t|
    t.string   "expiration_month", :default => "", :null => false
    t.string   "expiration_year",  :default => "", :null => false
    t.string   "last_4",           :default => "", :null => false
    t.string   "customer_token",   :default => "", :null => false
    t.string   "card_token",       :default => "", :null => false
    t.string   "issuer",           :default => "", :null => false
    t.integer  "user_id"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "billing_informations", ["user_id"], :name => "index_billing_informations_on_user_id"

  create_table "board_memberships", :force => true do |t|
    t.boolean  "is_current",                       :default => true
    t.boolean  "is_client_admin",                  :default => false
    t.integer  "points",                           :default => 0
    t.integer  "tickets",                          :default => 0
    t.integer  "ticket_threshold_base",            :default => 0
    t.integer  "location_id"
    t.integer  "demo_id"
    t.integer  "user_id"
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
    t.boolean  "displayed_tile_post_guide",        :default => false
    t.boolean  "displayed_tile_success_guide",     :default => false
    t.boolean  "not_show_onboarding",              :default => false
    t.boolean  "digest_muted",                     :default => false
    t.boolean  "followup_muted",                   :default => false
    t.boolean  "allowed_to_make_tile_suggestions", :default => false, :null => false
    t.boolean  "send_weekly_activity_report",      :default => true
  end

  add_index "board_memberships", ["demo_id"], :name => "index_board_memberships_on_demo_id"
  add_index "board_memberships", ["user_id"], :name => "index_board_memberships_on_user_id"

  create_table "bonus_thresholds", :force => true do |t|
    t.integer  "min_points", :null => false
    t.integer  "max_points", :null => false
    t.integer  "award",      :null => false
    t.integer  "demo_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "bonus_thresholds", ["demo_id"], :name => "index_bonus_thresholds_on_demo_id"
  add_index "bonus_thresholds", ["max_points"], :name => "index_bonus_thresholds_on_max_points"
  add_index "bonus_thresholds", ["min_points"], :name => "index_bonus_thresholds_on_min_points"

  create_table "bonus_thresholds_users", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "bonus_threshold_id"
  end

  add_index "bonus_thresholds_users", ["bonus_threshold_id"], :name => "index_bonus_thresholds_users_on_bonus_threshold_id"
  add_index "bonus_thresholds_users", ["user_id"], :name => "index_bonus_thresholds_users_on_user_id"

  create_table "characteristics", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.text     "allowed_values"
    t.integer  "demo_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "datatype"
  end

  add_index "characteristics", ["demo_id"], :name => "index_characteristics_on_demo_id"

  create_table "claim_attempt_histories", :force => true do |t|
    t.string   "from",              :default => "", :null => false
    t.text     "claim_information"
    t.integer  "claim_state_id"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.integer  "demo_id"
  end

  add_index "claim_attempt_histories", ["demo_id"], :name => "index_claim_attempt_histories_on_demo_id"
  add_index "claim_attempt_histories", ["from"], :name => "index_claim_attempt_histories_on_from"

  create_table "claim_state_machines", :force => true do |t|
    t.text     "states"
    t.integer  "demo_id"
    t.integer  "start_state_id", :default => 1
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "claim_state_machines", ["demo_id"], :name => "index_claim_state_machines_on_demo_id"

  create_table "custom_invitation_emails", :force => true do |t|
    t.text     "custom_html_text"
    t.text     "custom_plain_text"
    t.text     "custom_subject"
    t.text     "custom_subject_with_referrer"
    t.integer  "demo_id"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  add_index "custom_invitation_emails", ["demo_id"], :name => "index_custom_invitation_emails_on_demo_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.string   "queue"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "demos", :force => true do |t|
    t.string   "name",                                                 :default => "",                :null => false
    t.datetime "created_at",                                                                          :null => false
    t.datetime "updated_at",                                                                          :null => false
    t.integer  "seed_points",                                          :default => 0
    t.string   "custom_welcome_message",                :limit => 160
    t.datetime "ends_at"
    t.string   "followup_welcome_message",              :limit => 160, :default => "",                :null => false
    t.integer  "followup_welcome_message_delay",                       :default => 20
    t.integer  "credit_game_referrer_threshold"
    t.integer  "game_referrer_bonus"
    t.boolean  "use_standard_playbook",                                :default => true,              :null => false
    t.datetime "begins_at"
    t.string   "phone_number"
    t.string   "prize",                                                :default => "",                :null => false
    t.string   "help_message",                                         :default => "",                :null => false
    t.string   "email"
    t.string   "unrecognized_user_message"
    t.string   "act_too_early_message",                                :default => "",                :null => false
    t.string   "act_too_late_message",                                 :default => "",                :null => false
    t.integer  "referred_credit_bonus"
    t.string   "survey_answer_activity_message",                       :default => "",                :null => false
    t.string   "login_announcement",                    :limit => 500
    t.datetime "total_user_rankings_last_updated_at"
    t.datetime "average_user_rankings_last_updated_at"
    t.integer  "mute_notice_threshold"
    t.text     "join_type",                                            :default => "pre-populated",   :null => false
    t.string   "sponsor"
    t.string   "example_tooltip"
    t.string   "example_tutorial"
    t.integer  "ticket_threshold",                                     :default => 20
    t.string   "client_name",                                          :default => "",                :null => false
    t.string   "custom_reply_email_name"
    t.string   "custom_already_claimed_message"
    t.boolean  "use_post_act_summaries",                               :default => true
    t.string   "custom_support_reply"
    t.text     "internal_domains"
    t.boolean  "show_invite_modal_when_game_closed",                   :default => false
    t.datetime "tile_digest_email_sent_at"
    t.string   "tutorial_type",                                        :default => "multiple_choice"
    t.boolean  "unclaimed_users_also_get_digest",                      :default => true
    t.string   "public_slug"
    t.boolean  "is_public",                                            :default => true
    t.boolean  "upload_in_progress"
    t.datetime "users_last_loaded"
    t.boolean  "is_paid",                                              :default => false
    t.datetime "tile_last_posted_at"
    t.boolean  "turn_off_admin_onboarding",                            :default => false
    t.boolean  "use_location_in_conversion",                           :default => false
    t.string   "persistent_message",                                   :default => ""
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.boolean  "allow_raw_in_persistent_message",                      :default => false
    t.boolean  "is_parent",                                            :default => false,             :null => false
    t.boolean  "everyone_can_make_tile_suggestions",                   :default => false,             :null => false
  end

  add_index "demos", ["public_slug"], :name => "index_demos_on_public_slug"

  create_table "email_commands", :force => true do |t|
    t.integer  "user_id"
    t.string   "status"
    t.string   "email_to"
    t.string   "email_from"
    t.string   "email_subject"
    t.text     "email_plain"
    t.text     "clean_body"
    t.string   "response"
    t.datetime "response_sent"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.text     "clean_subject"
  end

  add_index "email_commands", ["user_id"], :name => "index_email_commands_on_user_id"

  create_table "email_info_requests", :force => true do |t|
    t.string   "email",      :default => "(email not entered)"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.string   "name",       :default => "(name not entered)"
    t.text     "comment",    :default => ""
    t.string   "phone"
    t.string   "role"
    t.string   "size"
    t.string   "company"
    t.string   "source"
  end

  create_table "follow_up_digest_emails", :force => true do |t|
    t.integer  "demo_id"
    t.text     "tile_ids"
    t.date     "send_on"
    t.boolean  "unclaimed_users_also_get_digest"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.string   "original_digest_subject"
    t.string   "original_digest_headline"
    t.text     "user_ids_to_deliver_to"
  end

  add_index "follow_up_digest_emails", ["demo_id"], :name => "index_follow_up_digest_emails_on_demo_id"

  create_table "former_friendships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "former_friendships", ["friend_id"], :name => "index_former_friendships_on_friend_id"
  add_index "former_friendships", ["user_id"], :name => "index_former_friendships_on_user_id"

  create_table "friendships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.string   "state",         :default => "pending", :null => false
    t.integer  "request_index"
  end

  add_index "friendships", ["friend_id"], :name => "index_friendships_on_friend_id"
  add_index "friendships", ["request_index"], :name => "index_friendships_on_request_index"
  add_index "friendships", ["state", "user_id"], :name => "index_friendships_on_state_and_user_id"

  create_table "game_creation_requests", :force => true do |t|
    t.string   "customer_name",  :default => "", :null => false
    t.string   "customer_email", :default => "", :null => false
    t.string   "company_name",   :default => "", :null => false
    t.text     "interests",      :default => "", :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  create_table "goal_completions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "goal_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "goal_completions", ["goal_id"], :name => "index_goal_completions_on_goal_id"
  add_index "goal_completions", ["user_id"], :name => "index_goal_completions_on_user_id"

  create_table "goals", :force => true do |t|
    t.string   "name",                :default => "", :null => false
    t.integer  "demo_id"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.string   "achievement_text",    :default => "", :null => false
    t.string   "completion_sms_text", :default => "", :null => false
  end

  add_index "goals", ["demo_id"], :name => "index_goals_on_demo_id"

  create_table "guest_users", :force => true do |t|
    t.integer  "points",                               :default => 0
    t.integer  "tickets",                              :default => 0
    t.integer  "ticket_threshold_base",                :default => 0
    t.integer  "demo_id"
    t.datetime "created_at",                                             :null => false
    t.datetime "updated_at",                                             :null => false
    t.integer  "converted_user_id"
    t.boolean  "get_started_lightbox_displayed"
    t.datetime "last_acted_at"
    t.datetime "last_session_activity_at"
    t.boolean  "voteup_intro_seen"
    t.boolean  "share_link_intro_seen"
    t.boolean  "seeing_marketing_page_for_first_time", :default => true
  end

  add_index "guest_users", ["demo_id"], :name => "index_guest_users_on_demo_id"

  create_table "image_containers", :force => true do |t|
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "incoming_sms", :force => true do |t|
    t.string   "from"
    t.string   "body"
    t.string   "twilio_sid"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "keys", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "keys", ["name"], :name => "index_keys_on_name"

  create_table "labels", :force => true do |t|
    t.integer  "rule_id"
    t.integer  "tag_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "labels", ["rule_id", "tag_id"], :name => "index_labels_on_rule_id_and_tag_id"

  create_table "levels", :force => true do |t|
    t.string   "name",              :default => "", :null => false
    t.integer  "threshold",                         :null => false
    t.integer  "demo_id"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.integer  "index_within_demo"
  end

  add_index "levels", ["demo_id"], :name => "index_levels_on_demo_id"
  add_index "levels", ["threshold"], :name => "index_levels_on_threshold"

  create_table "levels_users", :id => false, :force => true do |t|
    t.integer "level_id"
    t.integer "user_id"
  end

  add_index "levels_users", ["level_id"], :name => "index_levels_users_on_level_id"
  add_index "levels_users", ["user_id"], :name => "index_levels_users_on_user_id"

  create_table "locations", :force => true do |t|
    t.string   "name",            :default => "", :null => false
    t.integer  "demo_id"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.string   "normalized_name"
  end

  add_index "locations", ["demo_id"], :name => "index_locations_on_demo_id"
  add_index "locations", ["name"], :name => "location_name_trigram"
  add_index "locations", ["normalized_name"], :name => "location_normalized_name_trigram"

  create_table "more_info_requests", :force => true do |t|
    t.string   "phone_number"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "command"
    t.integer  "user_id"
  end

  add_index "more_info_requests", ["user_id"], :name => "index_more_info_requests_on_user_id"

  create_table "outgoing_emails", :force => true do |t|
    t.string   "subject"
    t.string   "from"
    t.text     "to"
    t.text     "raw"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "outgoing_emails", ["created_at"], :name => "index_outgoing_emails_on_created_at"
  add_index "outgoing_emails", ["subject"], :name => "index_outgoing_emails_on_subject"
  add_index "outgoing_emails", ["to"], :name => "index_outgoing_emails_on_to"

  create_table "outgoing_sms", :force => true do |t|
    t.string   "body"
    t.string   "to"
    t.integer  "mate_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "outgoing_sms", ["mate_id"], :name => "index_outgoing_sms_on_mate_id"

  create_table "parent_board_users", :force => true do |t|
    t.integer  "points",                   :default => 0
    t.integer  "tickets",                  :default => 0
    t.integer  "ticket_threshold_base",    :default => 0
    t.integer  "demo_id"
    t.integer  "user_id"
    t.datetime "last_acted_at"
    t.datetime "last_session_activity_at"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  create_table "payments", :force => true do |t|
    t.text     "raw_stripe_charge"
    t.integer  "amount"
    t.integer  "user_id"
    t.integer  "demo_id"
    t.integer  "balance_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "payments", ["demo_id", "user_id"], :name => "index_payments_on_demo_id_and_user_id"

  create_table "peer_invitations", :force => true do |t|
    t.integer  "inviter_id"
    t.integer  "invitee_id"
    t.integer  "demo_id"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.string   "invitee_type", :default => "User"
  end

  add_index "peer_invitations", ["created_at"], :name => "index_peer_invitations_on_created_at"
  add_index "peer_invitations", ["demo_id"], :name => "index_peer_invitations_on_demo_id"
  add_index "peer_invitations", ["invitee_id"], :name => "index_peer_invitations_on_invitee_id"
  add_index "peer_invitations", ["inviter_id"], :name => "index_peer_invitations_on_inviter_id"

  create_table "potential_users", :force => true do |t|
    t.string   "email"
    t.string   "invitation_code"
    t.integer  "demo_id"
    t.integer  "game_referrer_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "prerequisites", :force => true do |t|
    t.integer "prerequisite_tile_id", :null => false
    t.integer "tile_id",              :null => false
  end

  add_index "prerequisites", ["prerequisite_tile_id"], :name => "index_prerequisites_on_prerequisite_id"
  add_index "prerequisites", ["tile_id"], :name => "index_prerequisites_on_task_id"

  create_table "push_messages", :force => true do |t|
    t.text     "subject"
    t.text     "plain_text"
    t.text     "html_text"
    t.string   "sms_text",                    :limit => 160
    t.string   "state",                                      :default => "scheduled"
    t.datetime "scheduled_for"
    t.text     "email_recipient_ids"
    t.text     "sms_recipient_ids"
    t.text     "segment_description"
    t.integer  "demo_id"
    t.datetime "created_at",                                                          :null => false
    t.datetime "updated_at",                                                          :null => false
    t.boolean  "respect_notification_method"
    t.string   "segment_query_columns"
    t.string   "segment_query_operators"
    t.string   "segment_query_values"
  end

  create_table "raffles", :force => true do |t|
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.text     "prizes"
    t.text     "other_info"
    t.string   "status"
    t.integer  "demo_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "delayed_job_id"
  end

  create_table "rule_values", :force => true do |t|
    t.string   "value"
    t.boolean  "is_primary", :default => false, :null => false
    t.integer  "rule_id"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "rule_values", ["is_primary"], :name => "index_rule_values_on_is_primary"
  add_index "rule_values", ["rule_id"], :name => "index_rule_values_on_rule_id"

  create_table "rules", :force => true do |t|
    t.integer  "points"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.string   "reply",           :default => "",   :null => false
    t.string   "type"
    t.string   "description"
    t.integer  "alltime_limit"
    t.integer  "referral_points"
    t.boolean  "suggestible",     :default => true, :null => false
    t.integer  "demo_id"
    t.integer  "goal_id"
    t.integer  "primary_tag_id"
  end

  add_index "rules", ["demo_id"], :name => "index_rules_on_demo_id"
  add_index "rules", ["goal_id", "primary_tag_id"], :name => "index_rules_on_goal_id_and_primary_tag_id"

  create_table "suggestions", :force => true do |t|
    t.string   "value",      :default => "", :null => false
    t.integer  "user_id"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "suggestions", ["user_id"], :name => "index_suggestions_on_user_id"

  create_table "survey_answers", :force => true do |t|
    t.integer  "user_id"
    t.integer  "survey_question_id"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.integer  "survey_valid_answer_id"
  end

  add_index "survey_answers", ["survey_question_id"], :name => "index_survey_answers_on_survey_question_id"
  add_index "survey_answers", ["survey_valid_answer_id"], :name => "index_survey_answers_on_survey_valid_answer_id"
  add_index "survey_answers", ["user_id"], :name => "index_survey_answers_on_user_id"

  create_table "survey_prompts", :force => true do |t|
    t.datetime "send_time",                  :null => false
    t.string   "text",       :default => "", :null => false
    t.integer  "survey_id"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "survey_prompts", ["survey_id"], :name => "index_survey_prompts_on_survey_id"

  create_table "survey_questions", :force => true do |t|
    t.string   "text",       :default => "", :null => false
    t.integer  "index",                      :null => false
    t.integer  "survey_id"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "points"
  end

  add_index "survey_questions", ["index"], :name => "index_survey_questions_on_index"
  add_index "survey_questions", ["survey_id"], :name => "index_survey_questions_on_survey_id"

  create_table "survey_valid_answers", :force => true do |t|
    t.string   "value",              :default => "", :null => false
    t.integer  "survey_question_id"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "survey_valid_answers", ["survey_question_id"], :name => "index_survey_valid_answers_on_survey_question_id"
  add_index "survey_valid_answers", ["value"], :name => "index_survey_valid_answers_on_value"

  create_table "surveys", :force => true do |t|
    t.string   "name",       :default => "", :null => false
    t.integer  "demo_id"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.datetime "open_at",                    :null => false
    t.datetime "close_at"
  end

  add_index "surveys", ["close_at"], :name => "index_surveys_on_close_at"
  add_index "surveys", ["demo_id"], :name => "index_surveys_on_demo_id"
  add_index "surveys", ["open_at"], :name => "index_surveys_on_open_at"

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "daily_limit"
  end

  create_table "tile_completions", :force => true do |t|
    t.integer  "tile_id"
    t.integer  "user_id"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.boolean  "displayed_one_final_time",  :default => false, :null => false
    t.string   "user_type"
    t.integer  "answer_index"
    t.boolean  "not_show_in_tile_progress", :default => false
  end

  add_index "tile_completions", ["tile_id"], :name => "index_task_suggestions_on_task_id"
  add_index "tile_completions", ["user_id"], :name => "index_task_suggestions_on_user_id"
  add_index "tile_completions", ["user_type"], :name => "index_tile_completions_on_user_type"

  create_table "tile_images", :force => true do |t|
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "thumbnail_file_name"
    t.string   "thumbnail_content_type"
    t.integer  "thumbnail_file_size"
    t.datetime "thumbnail_updated_at"
    t.boolean  "image_processing"
    t.boolean  "thumbnail_processing"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
  end

  create_table "tile_taggings", :force => true do |t|
    t.integer  "tile_id"
    t.integer  "tile_tag_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "tile_taggings", ["tile_id"], :name => "index_tile_taggings_on_tile_id"
  add_index "tile_taggings", ["tile_tag_id"], :name => "index_tile_taggings_on_tile_tag_id"

  create_table "tile_tags", :force => true do |t|
    t.string   "title",      :default => ""
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "tile_viewings", :force => true do |t|
    t.integer  "tile_id"
    t.integer  "user_id"
    t.string   "user_type"
    t.integer  "views",      :default => 1
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "tile_viewings", ["tile_id", "user_id", "user_type"], :name => "index_tile_viewings_on_tile_and_user", :unique => true

  create_table "tiles", :force => true do |t|
    t.integer  "demo_id"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.datetime "start_time"
    t.integer  "bonus_points",            :default => 0,     :null => false
    t.datetime "end_time"
    t.integer  "position"
    t.boolean  "poly",                    :default => false, :null => false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "headline",                :default => "",    :null => false
    t.string   "thumbnail_file_name"
    t.string   "thumbnail_content_type"
    t.integer  "thumbnail_file_size"
    t.datetime "thumbnail_updated_at"
    t.boolean  "require_images",          :default => true,  :null => false
    t.text     "image_meta"
    t.text     "thumbnail_meta"
    t.text     "link_address",            :default => ""
    t.text     "supporting_content",      :default => ""
    t.text     "question",                :default => ""
    t.string   "status"
    t.text     "multiple_choice_answers"
    t.string   "type"
    t.integer  "correct_answer_index"
    t.integer  "points"
    t.datetime "activated_at"
    t.datetime "archived_at"
    t.boolean  "image_processing"
    t.boolean  "thumbnail_processing"
    t.boolean  "is_public",               :default => false, :null => false
    t.boolean  "is_copyable",             :default => false, :null => false
    t.integer  "creator_id"
    t.integer  "original_creator_id"
    t.datetime "original_created_at"
    t.string   "question_type"
    t.string   "question_subtype"
    t.text     "image_credit"
    t.boolean  "is_sharable",             :default => false, :null => false
    t.integer  "tile_completions_count",  :default => 0
    t.integer  "explore_page_priority"
    t.integer  "unique_viewings_count",   :default => 0,     :null => false
    t.integer  "total_viewings_count",    :default => 0,     :null => false
    t.integer  "user_tile_copies_count",  :default => 0
    t.integer  "user_tile_likes_count",   :default => 0
  end

  add_index "tiles", ["is_copyable"], :name => "index_tiles_on_is_copyable"
  add_index "tiles", ["is_public"], :name => "index_tiles_on_is_public"

  create_table "timed_bonus", :force => true do |t|
    t.datetime "expires_at",                    :null => false
    t.boolean  "fulfilled",  :default => false, :null => false
    t.integer  "points",                        :null => false
    t.string   "sms_text",   :default => "",    :null => false
    t.integer  "user_id"
    t.integer  "demo_id"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "timed_bonus", ["demo_id", "user_id"], :name => "index_timed_bonus_on_demo_id_and_user_id"

  create_table "trigger_demographic_triggers", :force => true do |t|
    t.integer  "tile_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "trigger_demographic_triggers", ["tile_id"], :name => "index_trigger_demographic_triggers_on_task_id"

  create_table "trigger_rule_triggers", :force => true do |t|
    t.integer  "rule_id"
    t.integer  "tile_id"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.boolean  "referrer_required", :default => false, :null => false
  end

  add_index "trigger_rule_triggers", ["referrer_required"], :name => "index_trigger_rule_triggers_on_referrer_required"
  add_index "trigger_rule_triggers", ["rule_id"], :name => "index_trigger_rule_triggers_on_rule_id"
  add_index "trigger_rule_triggers", ["tile_id"], :name => "index_trigger_rule_triggers_on_task_id"

  create_table "trigger_survey_triggers", :force => true do |t|
    t.integer  "survey_id"
    t.integer  "tile_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "trigger_survey_triggers", ["survey_id"], :name => "index_trigger_survey_triggers_on_survey_id"
  add_index "trigger_survey_triggers", ["tile_id"], :name => "index_trigger_survey_triggers_on_task_id"

  create_table "tutorials", :force => true do |t|
    t.integer  "user_id",                         :null => false
    t.datetime "ended_at"
    t.boolean  "completed",    :default => false, :null => false
    t.integer  "current_step", :default => 0,     :null => false
    t.integer  "friend_id"
    t.text     "first_act",    :default => "",    :null => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "tutorials", ["user_id"], :name => "index_tutorials_on_user_id"

  create_table "unsubscribes", :force => true do |t|
    t.integer  "user_id",                    :null => false
    t.text     "reason",     :default => "", :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "unsubscribes", ["user_id"], :name => "index_unsubscribes_on_user_id"

  create_table "user_in_raffle_infos", :force => true do |t|
    t.integer  "user_id"
    t.integer  "raffle_id"
    t.boolean  "start_showed",  :default => false,  :null => false
    t.boolean  "finish_showed", :default => false,  :null => false
    t.boolean  "in_blacklist",  :default => false,  :null => false
    t.boolean  "is_winner",     :default => false,  :null => false
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.string   "user_type",     :default => "User"
  end

  add_index "user_in_raffle_infos", ["user_id", "user_type", "raffle_id"], :name => "user_in_raffle", :unique => true

  create_table "user_tile_copies", :force => true do |t|
    t.integer  "tile_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "user_tile_copies", ["tile_id"], :name => "index_user_tile_copies_on_tile_id"
  add_index "user_tile_copies", ["user_id"], :name => "index_user_tile_copies_on_user_id"

  create_table "user_tile_likes", :force => true do |t|
    t.integer  "tile_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "user_tile_likes", ["tile_id", "user_id"], :name => "index_user_tile_likes_on_tile_id_and_user_id", :unique => true
  add_index "user_tile_likes", ["tile_id"], :name => "index_user_tile_likes_on_tile_id"
  add_index "user_tile_likes", ["user_id"], :name => "index_user_tile_likes_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "name",                                                :default => "",          :null => false
    t.string   "email",                                               :default => "",          :null => false
    t.boolean  "invited",                                             :default => false
    t.datetime "created_at",                                                                   :null => false
    t.datetime "updated_at",                                                                   :null => false
    t.string   "invitation_code",                                     :default => "",          :null => false
    t.string   "phone_number",                                        :default => "",          :null => false
    t.integer  "points",                                              :default => 0,           :null => false
    t.string   "encrypted_password",                   :limit => 128
    t.string   "salt",                                 :limit => 128
    t.string   "remember_token",                       :limit => 128
    t.string   "slug",                                                :default => "",          :null => false
    t.string   "claim_code"
    t.string   "confirmation_token",                   :limit => 128
    t.datetime "won_at"
    t.string   "sms_slug",                                            :default => "",          :null => false
    t.string   "last_suggested_items",                                :default => "",          :null => false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.integer  "ranking_query_offset"
    t.datetime "accepted_invitation_at"
    t.integer  "game_referrer_id"
    t.boolean  "is_site_admin",                                       :default => false,       :null => false
    t.string   "notification_method",                                 :default => "email",     :null => false
    t.integer  "location_id"
    t.string   "new_phone_number",                                    :default => "",          :null => false
    t.string   "new_phone_validation",                                :default => "",          :null => false
    t.date     "date_of_birth"
    t.string   "gender"
    t.string   "invitation_method",                                   :default => "",          :null => false
    t.integer  "session_count",                                       :default => 0,           :null => false
    t.string   "privacy_level",                                       :default => "connected", :null => false
    t.datetime "last_muted_at"
    t.datetime "last_told_about_mute"
    t.integer  "mt_texts_today",                                      :default => 0,           :null => false
    t.boolean  "suppress_mute_notice",                                :default => false
    t.datetime "follow_up_message_sent_at"
    t.text     "flashes_for_next_request"
    t.text     "characteristics"
    t.string   "overflow_email",                                      :default => ""
    t.integer  "tickets",                                             :default => 0,           :null => false
    t.string   "zip_code"
    t.boolean  "is_employee",                                         :default => true
    t.string   "ssn_hash"
    t.string   "employee_id"
    t.integer  "spouse_id"
    t.datetime "last_acted_at"
    t.boolean  "is_client_admin",                                     :default => false
    t.integer  "ticket_threshold_base",                               :default => 0
    t.boolean  "sample_tile_completed"
    t.boolean  "get_started_lightbox_displayed"
    t.integer  "original_guest_user_id"
    t.string   "cancel_account_token"
    t.datetime "last_session_activity_at"
    t.boolean  "has_own_tile_completed",                              :default => false
    t.boolean  "displayed_tile_post_guide",                           :default => false
    t.boolean  "displayed_tile_success_guide",                        :default => false
    t.boolean  "displayed_activity_page_admin_guide",                 :default => false
    t.boolean  "displayed_active_tile_guide",                         :default => false
    t.boolean  "has_own_tile_completed_displayed",                    :default => false
    t.integer  "has_own_tile_completed_id"
    t.string   "explore_token"
    t.boolean  "voteup_intro_seen"
    t.boolean  "is_test_user"
    t.boolean  "share_link_intro_seen"
    t.boolean  "share_section_intro_seen"
    t.string   "mixpanel_distinct_id"
    t.datetime "last_unmonitored_mailbox_response_at"
    t.boolean  "allowed_to_make_tile_suggestions",                    :default => false,       :null => false
    t.boolean  "submitted_tile_menu_intro_seen",                      :default => false,       :null => false
    t.boolean  "submit_tile_intro_seen",                              :default => false,       :null => false
    t.boolean  "send_weekly_activity_report",                         :default => true
  end

  add_index "users", ["cancel_account_token"], :name => "index_users_on_cancel_account_token"
  add_index "users", ["claim_code"], :name => "index_users_on_claim_code"
  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["email"], :name => "user_email_trigram"
  add_index "users", ["employee_id"], :name => "index_users_on_employee_id"
  add_index "users", ["explore_token"], :name => "index_users_on_explore_token"
  add_index "users", ["game_referrer_id"], :name => "index_users_on_game_referrer_id"
  add_index "users", ["invitation_code"], :name => "index_users_on_invitation_code"
  add_index "users", ["is_employee"], :name => "index_users_on_is_employee"
  add_index "users", ["location_id"], :name => "index_users_on_location_id"
  add_index "users", ["name"], :name => "user_name_trigram"
  add_index "users", ["overflow_email"], :name => "index_users_on_overflow_email"
  add_index "users", ["phone_number"], :name => "index_users_on_phone_number"
  add_index "users", ["privacy_level"], :name => "index_users_on_privacy_level"
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"
  add_index "users", ["slug"], :name => "index_users_on_slug"
  add_index "users", ["slug"], :name => "user_slug_trigram"
  add_index "users", ["sms_slug"], :name => "index_users_on_sms_slug"
  add_index "users", ["spouse_id"], :name => "index_users_on_spouse_id"
  add_index "users", ["ssn_hash"], :name => "index_users_on_ssn_hash"
  add_index "users", ["zip_code"], :name => "index_users_on_zip_code"

end
