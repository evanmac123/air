Feature: Player can win the game

# But not you. You just lost the game.

  Background:
    Given the following demo exists:
      | company_name | victory_threshold | victory_verification_email | victory_verification_sms_number |
      | BobCo        | 100               | lucille@example.com        | +16179876543                    |
    And the following demo exists:
      | company name | victory threshold | custom victory achievement message | custom victory sms                     | custom victory scoreboard message |
      | CustomCo     | 100               | You did it at %{winning_time}!     | You go boy with your %{points} points! | Did a big thing!                  |
    And the following users exist:
      | name | email           | phone_number | points | demo                   |
      | Bob  | bob@example.com | +14155551212 | 97     | company_name: BobCo    |
      | Jim  | jim@example.com | +16175551212 | 97     | company_name: CustomCo |
    And "Bob" has the password "LOL"
    And "Jim" has the password "LOL"
    And the following rules exist:
      | points | reply    | demo                   |
      | 3      | kitten 1 | company_name: BobCo    |
      | 3      | kitten 2 | company_name: CustomCo |
    And the following rule values exist:
      | value        | rule            |
      | ate a kitten | reply: kitten 1 |
      | ate a kitten | reply: kitten 2 |
    And I sign in via the login page as "Bob/LOL"

  Scenario: Player hasn't won yet
    When I go to the activity page
    Then I should not see "You won on"

  Scenario: Player wins by scoring enough points
    When "+14155551212" sends SMS "ate a kitten"
    And DJ cranks once
    And I go to the activity page
    Then "+14155551212" should have received an SMS "Congratulations! You've got 100 points and have qualified for the drawing!"
    And I should see "You won on"
    
  Scenario: Victory admin gets SMS notification
    When "+14155551212" sends SMS "ate a kitten"
    And DJ cranks 10 times
    Then "+16179876543" should have received an SMS "Bob (bob@example.com) won with 100 points"

  Scenario: Victory admin gets email notification
    When time is frozen at "2010-03-04 17:23:00"
    And "+14155551212" sends SMS "ate a kitten"
    And "lucille@example.com" opens the email with subject "HEngage victory notification: Bob \(bob@example.com\)"
    Then I should see "Bob (bob@example.com) won the game with 100 points on March 04, 2010 at 05:23 PM Eastern" in the email body

  Scenario: Player wins just once
    When "+14155551212" sends SMS "ate a kitten"
    And "+14155551212" sends SMS "ate a kitten"
    And DJ cranks 10 times
    Then "+14155551212" should have received an SMS "Congratulations! You've got 100 points and have qualified for the drawing!"
    And "+14155551212" should not have received an SMS "Congratulations! You've got 103 points and have qualified for the drawing!"

  Scenario: Other players have won
    Given the following user with phones exist:
      | demo                | name | won_at              |
      | company_name: BobCo | Dan  | 2005-12-31 06:00:00 |
    When I go to the activity page
    Then I should see "Won game!"

  Scenario: Player wins a game with custom victory messages
    Given I sign in via the login page as "Jim/LOL"
    And time is frozen at "2011-05-01 13:25:00 EDT"
    And "+16175551212" sends SMS "ate a kitten"
    And DJ cranks once
    When I go to the activity page
    Then I should see "You did it at May 01, 2011 at 01:25 PM Eastern!"
    And "+16175551212" should have received SMS "You go boy with your 100 points!"

  Scenario: Looking at another player with a custom scoreboard victory message
    Given the following user with phones exist:
      | demo                   | name | won_at              |
      | company_name: CustomCo | Dan  | 2005-12-31 06:00:00 |
    When I sign in via the login page as "Jim/LOL"
    And I go to the activity page
    Then I should see "Did a big thing!"
