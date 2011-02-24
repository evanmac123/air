Feature: Player can win the game

# But not you. You just lost the game.

  Background:
    Given the following demo exists:
      | company_name | victory_threshold | victory_verification_email | victory_verification_sms_number |
      | BobCo        | 100               | lucille@example.com        | +16179876543                    |
    Given the following user exists:
      | name | email           | phone_number | points | demo                |
      | Bob  | bob@example.com | +14155551212 | 97     | company_name: BobCo |
    And "Bob" has the password "LOL"
    And the following rule exists:
      | points | key       | value    | 
      | 3      | name: ate | a kitten |
    And I sign in via the login page as "Bob/LOL"

  Scenario: Player hasn't won yet
    When I go to the activity page
    Then I should not see "You won on"

  Scenario: Player wins by scoring enough points
    When "+14155551212" sends SMS "ate a kitten"
    And I go to the activity page
    Then "+14155551212" should have received an SMS "Congratulations! You've scored 100 points and won the game!"
    And I should see "You won on"
    
  Scenario: Victory admin gets SMS notification
    When "+14155551212" sends SMS "ate a kitten"
    Then "+16179876543" should have received an SMS "Bob (bob@example.com) won with 100 points"

  Scenario: Victory admin gets email notification
    When time is frozen at "2010-03-04 17:23:00"
    And "+14155551212" sends SMS "ate a kitten"
    And "lucille@example.com" opens the email with subject "HEngage victory notification: Bob \(bob@example.com\)"
    Then I should see "Bob (bob@example.com) won the game with 100 points on March 04, 2010 at 05:23 PM Eastern" in the email body

  Scenario: Player wins just once
    When "+14155551212" sends SMS "ate a kitten"
    And "+14155551212" sends SMS "ate a kitten"
    Then "+14155551212" should have received an SMS "Congratulations! You've scored 100 points and won the game!"
    And "+14155551212" should not have received an SMS "Congratulations! You've scored 103 points and won the game!"

  Scenario: Other players have won
    Given the following users exist:
      | demo                | name | won_at              |
      | company_name: BobCo | Dan  | 2005-12-31 06:00:00 |
    When I go to the activity page
    Then I should see "won on December 31, 2005 at 01:00 AM Eastern"
