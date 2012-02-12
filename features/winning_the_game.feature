Feature: Player can win the game

# But not you. You just lost the game.

  Background:
    Given the following demo exists:
      | name  | victory_threshold | victory_verification_email | victory_verification_sms_number |
      | BobCo | 100               | lucille@example.com        | +16179876543                    |
    And the following demo exists:
      | name     | victory threshold | custom victory achievement message | custom victory sms                     | custom victory scoreboard message |
      | CustomCo | 100               | You did it at %{winning_time}!     | You go boy with your %{points} points! | Did a big thing!                  |
    And the following claimed users exist:
      | name | email           | phone_number | points | demo                   |
      | Bob  | bob@example.com | +14155551212 | 97     | name: BobCo    |
      | Jim  | jim@example.com | +16175551212 | 97     | name: CustomCo |
    And "Bob" has the password "LOLWTF"
    And "Jim" has the password "LOLWTF"
    And the following rules exist:
      | points | reply    | demo           |
      | 3      | kitten 1 | name: BobCo    |
      | 3      | kitten 2 | name: CustomCo |
    And the following rule values exist:
      | value        | rule            |
      | ate a kitten | reply: kitten 1 |
      | ate a kitten | reply: kitten 2 |
    And I sign in via the login page as "Bob/LOLWTF"
    And time is frozen

  Scenario: Player hasn't won yet
    When I go to the activity page
    Then I should not see "You won on"

  Scenario: Player wins by SMS and gets notified by SMS 
    When "+14155551212" sends SMS "ate a kitten"
    And a decent interval has passed
    Given a clean email queue
    And DJ cranks 15 times
    And I go to the activity page
    Then "+14155551212" should have received an SMS "Congratulations! You've got 100 points and have qualified for the drawing!"
    But "bob@example.com" should receive no email

  Scenario: Player wins by email and gets notified by email 
    When "bob@example.com" sends email with subject "ate a kitten" and body "ate a kitten"
    And a decent interval has passed
    And DJ cranks 15 times
    And I go to the activity page
    Then "+14155551212" should not have received any SMSes
    But "bob@example.com" should receive an email with "Congratulations! You've got 100 points and have qualified for the drawing!" in the email body

  Scenario: Player wins by web and sees notification in the flash
    When I enter the act code "ate a kitten"
    And a decent interval has passed
    Given a clean email queue
    And DJ cranks 15 times
    Then "+14155551212" should not have received any SMSes
    And "bob@example.com" should receive no email
    But I should see "Congratulations! You've got 100 points and have qualified for the drawing!"
    
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
    And a decent interval has passed
    And DJ cranks 10 times
    Then "+14155551212" should have received an SMS "Congratulations! You've got 100 points and have qualified for the drawing!"
    And "+14155551212" should not have received an SMS "Congratulations! You've got 103 points and have qualified for the drawing!"

#   Scenario: Other players have won
    # Given the following user with phones exist:
      # | demo                | name | won_at              |
      # | name: BobCo | Dan  | 2005-12-31 06:00:00 |
    # When I go to the activity page
#     Then I should see the winning graphic

  Scenario: Player wins a game with custom victory messages
    Given I sign in via the login page as "Jim/LOLWTF"
    And "+16175551212" sends SMS "ate a kitten"
    And a decent interval has passed
    And DJ cranks 5 times
    # When I go to the activity page
    # Then I should see "You did it at December 31, 2009 at 07:00 PM Eastern!"
    And "+16175551212" should have received SMS "You go boy with your 100 points!"
