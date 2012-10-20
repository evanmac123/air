Feature: User completes tile

  Background:
    Given the following demo exists:
      | name   |
      | TileCo |
    And the following claimed user exists:
      | name | phone number | email           | demo         |
      | Joe  | +14152613077 | joe@example.com | name: TileCo |
      | Bob  | +14155551212 | bob@example.com | name: TileCo |
    And "Bob" has the SMS slug "bob"
    And "Bob" has the password "foobar"
    And "Joe" has the password "foobar"
    And the following tiles exist:
      | headline           | demo         |
      | Rule tile 1        | name: TileCo |
      | Rule tile 2        | name: TileCo |
      | Rule tile 3        | name: TileCo |
      | Rule tile 4        | name: TileCo |
      | Rule tile 5        | name: TileCo |
      | Rule tile 6        | name: TileCo |
      | Referer tile 1     | name: TileCo |
      | Referer tile 2     | name: TileCo |
      | Survey tile 1      | name: TileCo |
      | Survey tile 2      | name: TileCo |
      | Survey tile 3      | name: TileCo |
      | Survey tile 4      | name: TileCo |
      | Demographic tile 1 | name: TileCo |
      | Demographic tile 2 | name: TileCo |
    And the following rules exist:
      | reply | demo         |
      | did 1 | name: TileCo |
      | did 5 | name: TileCo |
    And the following rule value exists:
      | value | is primary | rule         |
      | do 1  | true       | reply: did 1 |
    And the following rule triggers exist:
      | rule         | tile                  |
      | reply: did 1 | headline: Rule tile 1 |
      | reply: did 5 | headline: Rule tile 5 |
    And the following rule triggers exist:
      | rule         | tile                 | referrer required |
      | reply: did 1 | headline: Referer tile 1 | true              |
    And demo "TileCo" open survey with name "Survey 1" exists
    And demo "TileCo" survey with name "Survey 2" exists
    And the following survey questions exist:
      | text  | index | survey         |
      | Q 1-1 | 1     | name: Survey 1 |
      | Q 1-2 | 2     | name: Survey 1 |
      | Q 1-3 | 3     | name: Survey 1 |
      | Q 2-1 | 1     | name: Survey 2 |
      | Q 2-2 | 2     | name: Survey 2 |
      | Q 2-3 | 3     | name: Survey 2 |
    And the following survey valid answers exist:
      | value | survey question |
      | 1     | text: Q 1-1     |
      | 2     | text: Q 1-1     |
      | 1     | text: Q 1-2     |
      | 2     | text: Q 1-2     |
      | 1     | text: Q 1-3     |
      | 2     | text: Q 1-3     |
      | 1     | text: Q 2-1     |
      | 2     | text: Q 2-1     |
      | 1     | text: Q 2-2     |
      | 2     | text: Q 2-2     |
      | 1     | text: Q 2-3     |
      | 2     | text: Q 2-3     |
    And the following survey triggers exist:
      | survey         | tile                    |
      | name: Survey 1 | headline: Survey tile 1 |
      | name: Survey 2 | headline: Survey tile 3 |
    And the following demographic triggers exist:
      | tile           |
      | headline: Demographic tile 1 |
    And the tile "Rule tile 2" has prerequisite "Rule tile 1"
    And the tile "Rule tile 4" has prerequisite "Rule tile 3"
    And the tile "Rule tile 6" has prerequisite "Rule tile 5"
    And the tile "Survey tile 2" has prerequisite "Survey tile 1"
    And the tile "Survey tile 4" has prerequisite "Survey tile 2"
    And the tile "Referer tile 2" has prerequisite "Referer tile 1"
    And the tile "Demographic tile 2" has prerequisite "Demographic tile 1"
    And DJ works off
    When I sign in via the login page with "Joe/foobar"
    Then I should see "Rule tile 1"
    And I should see "Rule tile 3"
    And I should see "Rule tile 5"
    And I should see "Survey tile 1"
    And I should see "Survey tile 3"
    And I should see "Referer tile 1"
    And I should see "Demographic tile 1"

    But I should not see "Rule tile 2"
    And I should not see "Rule tile 4"
    And I should not see "Rule tile 6"
    And I should not see "Survey tile 2"
    And I should not see "Survey tile 4"
    And I should not see "Referer tile 2"
    And I should not see "Demographic tile 2"
    And I should not see "I completed a game piece!"

  @javascript
  Scenario: User completes tile by acting according to rule
    When "+14152613077" sends SMS "do 1"
    Then "+14152613077" should have received an SMS including "did 1"
    When I go to the activity page
    # This takes care of the tutorial popup
    And I click "No thanks"
    Then I should see "Rule tile 2"
    And I should see "Rule tile 3"
    And I should see "Rule tile 5"
    And I should see "Survey tile 1"
    And I should see "Survey tile 3"
    And I should see "Referer tile 1"
    And I should see "Demographic tile 1"
    And I should see "I completed a game piece!"

    But I should not see "Rule tile 1"
    And I should not see "Rule tile 4"
    And I should not see "Rule tile 6"
    And I should not see "Survey tile 2"
    And I should not see "Survey tile 4"
    And I should not see "Referer tile 2"
    And I should not see "Demographic tile 2"

    When DJ works off after a little while
    Then "+14152613077" should have received an SMS "Congratulations! You've completed a game piece."

  Scenario: User completes rule tile by SMS and gets congrats by SMS
    Given a clear email queue
    When "+14152613077" sends SMS "do 1"
    When DJ works off after a little while
    Then "+14152613077" should have received an SMS "Congratulations! You've completed a game piece."
    But "joe@example.com" should receive no email

  Scenario: User completes rule tile by email and gets congrats by email
    When "joe@example.com" sends email with subject "do 1" and body "do 1"
    And DJ works off after a little while
    Then "+14152613077" should not have received any SMSes
    But "joe@example.com" should receive an email with "Congratulations! You've completed a game piece." in the email body

  Scenario: User completes rule tile on web and sees congrats in the flash
    When I sign in via the login page with "Joe/foobar" and choose to be remembered
    Given a clear email queue
    When I enter the act code "do 1"
    And DJ works off after a little while
    Then "+14152613077" should not have received any SMSes
    And "joe@example.com" should receive no email
    But I should see "Congratulations! You've completed a game piece."
    When I go to the activity page
    Then I should not see "Your session has expired"

  @javascript
  Scenario: User completes tile by acting according to rule with mandatory referrer
    When "+14152613077" sends SMS "do 1 bob"
    Then "+14152613077" should have received an SMS including "did 1"
    When I go to the activity page
    And I click "No thanks"

    Then I should see "Rule tile 2"
    And I should see "Rule tile 3"
    And I should see "Rule tile 5"
    And I should see "Survey tile 1"
    And I should see "Survey tile 3"
    And I should see "Referer tile 2"
    And I should see "Demographic tile 1"
    And I should see "I completed a game piece!"

    But I should not see "Rule tile 1"
    And I should not see "Rule tile 4"
    And I should not see "Rule tile 6"
    And I should not see "Survey tile 2"
    And I should not see "Survey tile 4"
    And I should not see "Referer tile 1"
    And I should not see "Demographic tile 2"

    When DJ works off after a little while
    Then "+14152613077" should have received an SMS "Congratulations! You've completed a game piece."

  @javascript
  Scenario: User completes tile by completing survey
    When "+14152613077" sends SMS "survey"
    And "+14152613077" sends SMS "1"
    And "+14152613077" sends SMS "1"
    And "+14152613077" sends SMS "1"
    Then "+14152613077" should have received an SMS including "Thanks for completing the survey"
    When I go to the activity page
    And I click "No thanks"

    Then I should see "Rule tile 1"
    And I should see "Rule tile 3"
    And I should see "Rule tile 5"
    And I should see "Survey tile 2"
    And I should see "Survey tile 3"
    And I should see "Referer tile 1"
    And I should see "Demographic tile 1"
    And I should see "I completed a game piece!"

    But I should not see "Rule tile 2"
    And I should not see "Rule tile 4"
    And I should not see "Rule tile 6"
    And I should not see "Survey tile 1"
    And I should not see "Survey tile 4"
    And I should not see "Referer tile 2"
    And I should not see "Demographic tile 2"

    When DJ works off after a little while
    Then "+14152613077" should have received an SMS "Congratulations! You've completed a game piece."

  @javascript
  Scenario: User completes demographic tile by filling in their details
    When I go to the settings page
    And I fill in most of my demographic information
    And I press the button to save the user's settings
    And I go to the activity page
    And I click "No thanks"

    Then I should see "Demographic tile 1"
    But I should not see "Demographic tile 2"
    And I should not see "I completed a game piece!"

    When I go to the settings page
    And I fill in "Date of Birth" with "September 10, 1977"
    And I press the button to save the user's settings
    And I go to the activity page
    And I click "No thanks"

    Then I should see "Rule tile 1"
    And I should see "Rule tile 3"
    And I should see "Rule tile 5"
    And I should see "Survey tile 1"
    And I should see "Survey tile 3"
    And I should see "Referer tile 1"
    And I should not see "Demographic tile 1"
    And I should see "Demographic tile 2"
    And I should see "I completed a game piece!"

    But I should not see "Rule tile 2"
    And I should not see "Rule tile 4"
    And I should not see "Rule tile 6"
    And I should not see "Survey tile 2"
    And I should not see "Survey tile 4"
    And I should not see "Referer tile 2"
    And I should not see "Demographic tile 1"

    When DJ works off after a little while
    Then "+14152613077" should have received an SMS "Congratulations! You've completed a game piece."  
  
  Scenario: User completes survey tile by SMS and gets congrats by SMS
    Given a clear email queue
    When "+14152613077" sends SMS "1"
    And "+14152613077" sends SMS "1"
    And "+14152613077" sends SMS "1"
    When DJ works off after a little while
    Then "+14152613077" should have received an SMS "Congratulations! You've completed a game piece."
    But "joe@example.com" should receive no email

  Scenario: User completes survey tile by email and gets congrats by email
    When "joe@example.com" sends email with subject "1" and body "1"
    When "joe@example.com" sends email with subject "1" and body "1"
    When "joe@example.com" sends email with subject "1" and body "1"
    Then "+14152613077" should not have received any SMSes
    But "joe@example.com" should receive an email with "Congratulations! You've completed a game piece." in the email body

  Scenario: User completes survey tile on web and sees congrats in the flash
    When I sign in via the login page with "Joe/foobar"
    And I enter the act code "1"
    And I enter the act code "1"
    And I enter the act code "1"
    When DJ works off after a little while
    Then "+14152613077" should not have received any SMSes
    And "joe@example.com" should receive no email
    But I should see "Congratulations! You've completed a game piece."
