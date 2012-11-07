Feature: Admin edits existing demo

  Background:
    Given the following demo exists:
      | name  | seed_points | custom_welcome_message | begins_at               | ends_at                 | points_for_connecting | followup_welcome_message | followup_welcome_message_delay | credit_game_referrer_threshold | game_referrer_bonus |
      | FooCo | 10          | Hi there               | 2012-04-01 12:00:00 UTC | 2012-05-01 12:00:00 UTC | 5                     | Hi again.                | 20                             | 60                             | 5                   |
    And I sign in as an admin via the login page
    And I go to the admin "FooCo" demo page
    And I follow "Edit basic settings for this game"

  Scenario: Admin edits existing demo
    When I fill in the following:
      | Name                                                  | BarCo                        |
      | Starting player score                                 | 10                           |
      | Custom welcome message                                | Sup.                         |
      | Points for connecting to another player               | 20                           |
      | Followup welcome message                              | Did you figure it out?       |
      | Followup welcome message delay (in minutes)           | 666                          |
      | Bonus for referring another to the game               | 60                           |
      | Threshold to credit user who referred you to the game | 90                           |
    And I set the start time to "April/20/2013/6 AM/25"
    And I set the end time to "June/20/2014/7 AM/30"
    And I press "Update Game"
    Then I should be on the admin "BarCo" demo page
    And I should see "Game begins at April 20, 2013 at 06:25 AM Eastern"
    And I should see "Game ends at June 20, 2014 at 07:30 AM Eastern"
    And I should see "New players start with 10 points"
    And I should see "Welcome message: Sup."
    And I should see "Followup welcome message: Did you figure it out? (send 666 minutes after invitation accepted)"
    And I should see "Bonus for referring another user to the game: 60 points (with a 90 minute threshold)"
    And I should see "Points for connecting to another user: 20"
    
  Scenario: Admin blanks out certain values, and that means something
    When I fill in "Custom welcome message" with ""
    And I press "Update Game"
    Then I should be on the admin "FooCo" demo page
