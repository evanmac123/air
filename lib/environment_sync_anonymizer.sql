UPDATE demos
SET
  email = 'demo' || id || '@airbo.com',
  custom_reply_email_name = NULL,
  phone_number = NULL;

UPDATE users
SET
  email='user' || id || '@example.com',
  official_email = 'user' || id || '@example.com',
  overflow_email = '',
  phone_number = '',
  new_phone_number = ''
WHERE users.email NOT LIKE '%@airbo.com';

TRUNCATE TABLE email_commands;
TRUNCATE TABLE demo_requests;
TRUNCATE TABLE email_info_requests;
TRUNCATE TABLE lead_contacts;
TRUNCATE TABLE potential_users;
TRUNCATE TABLE searchjoy_searches;
TRUNCATE TABLE user_settings_change_logs;
TRUNCATE TABLE more_info_requests;
TRUNCATE TABLE bad_messages;
TRUNCATE TABLE game_creation_requests;
TRUNCATE TABLE delayed_jobs;
