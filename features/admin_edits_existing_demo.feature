Feature: Admin edits existing demo

  Background:
    Given the following demo exists:
      | company_name | victory_threshold | victory_verification_email | victory_verification_sms_number | seed_points | custom_welcome_message | begins_at               | ends_at                 | points_for_connecting | custom_victory_achievement_message | custom_victory_sms | custom_victory_scoreboard_message | followup_welcome_message | followup_welcome_message_delay | credit_game_referrer_threshold | game_referrer_bonus |
      | FooCo        | 50                | phil@fooco.com             | +14155551212                    | 10          | Hi there               | 2012-04-01 12:00:00 UTC | 2012-05-01 12:00:00 UTC | 5                     | You won.                           | You won by SMS     | Won a bunch                       | Hi again.                | 20                             | 60                             | 5                   |
    And I sign in as an admin via the login page
    And I go to the admin "FooCo" demo page
    And I follow "Edit basic settings for this game"

  Scenario: Admin edits existing demo
    When I fill in the following:
      | Company name                                          | BarCo                        |
      | Victory threshold                                     | 90                           |
      | Starting player score                                 | 10                           |
      | Custom welcome message                                | Sup.                         |
      | Custom victory achievement message                    | Do you want a cookie?        |
      | Custom victory SMS                                    | You did it in 140 characters |
      | Custom victory scoreboard message                     | Did the thing                |
      | Points for connecting to another player               | 20                           |
      | Followup welcome message                              | Did you figure it out?       |
      | Followup welcome message delay (in minutes)           | 666                          |
      | Victory verification email                            | phil@barco.com               |
      | Victory verification SMS number                       | +16175551212                 |
      | Bonus for referring another to the game               | 60                           |
      | Threshold to credit user who referred you to the game | 90                           |
    And I set the start time to "April/20/2013/6 AM/25"
    And I set the end time to "June/20/2014/7 AM/30"
    And I press "Submit"
    Then I should be on the admin "BarCo" demo page
    And I should see "Game begins at April 20, 2013 at 06:25 AM Eastern"
    And I should see "Game ends at June 20, 2014 at 07:30 AM Eastern"
    And I should see "90 points to win"
    And I should see "Victory email to phil@barco.com"
    And I should see "Victory verification SMS to +16175551212"
    And I should see "New players start with 10 points"
    And I should see "Welcome message: Sup."
    And I should see "Victory achievement message: Do you want a cookie?"
    And I should see "Victory SMS: You did it in 140 characters"
    And I should see "Victory scoreboard message: Did the thing"
    And I should see "Followup welcome message: Did you figure it out? (send 666 minutes after invitation accepted)"
    And I should see "Bonus for referring another user to the game: 60 points (with a 90 minute threshold)"
    And I should see "Points for connecting to another user: 20"
    
  Scenario: Admin blanks out certain values, and that means something
    When I fill in the following:
      | Custom welcome message                 | |
      | Custom victory achievement message     | |
      | Custom victory SMS                     | |
      | Custom victory scoreboard message      | |
      | Victory threshold                      | |
      | Victory verification email             | |
      | Victory verification SMS number        | |
    And I press "Submit"
    Then I should be on the admin "FooCo" demo page
    And I should see "Welcome message: You've joined the %{company_name} game! Your user ID is %{unique_id} (text MYID if you forget). To play, text to this #."
    And I should see "Victory achievement message: You won on %{winning_time}. Congratulations!"
    And I should see "Victory SMS: Congratulations! You've got %{points} points and have qualified for the drawing!"
    And I should see "Victory scoreboard message: Won game!"
    And I should not see "points to win"
    And I should not see "Victory email to"
    And I should not see "Victory verification SMS to"

