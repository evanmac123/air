Feature: User accepts invitation

  Background:
    Given the following users exist:
      | email           | name | demo             |
      | dan@example.com | Dan  | company name: 3M |
    And "dan@example.com" has received an invitation
    When "dan@example.com" opens the email
    And I click the first link in the email

  Scenario: User accepts invitation
    Then I should be on the invitation page for "dan@example.com"
    And I should see "Dan"
    When I fill in "Enter your mobile number" with "508-740-7520"
    And I fill in "Choose a password" with "whatwhat"
    And I fill in "And confirm that password" with "whatwhat"
    And I press "Join the game"
    Then "+15087407520" should have received an SMS "You've joined the 3M game! To play, send texts to this number. Send a text HELP if you want help."
    And I should be on the activity page

  Scenario: User sets password when accepting invitation
    When I fill in "Enter your mobile number" with "508-740-7520"
    And I fill in "Choose a password" with "whatwhat"
    And I fill in "And confirm that password" with "whatwhat"
    And I press "Join the game"
    And I sign out
    And I sign in via the login page as "Dan/whatwhat"
    And I should see "Signed in."

  Scenario: User must set password when accepting invitation
    When I fill in "Enter your mobile number" with "508-740-7520"
    And I press "Join the game"
    Then I should be on the invitation page for "dan@example.com"
    And I should not see "You're now signed in."
    And I should see "Please choose a password."
