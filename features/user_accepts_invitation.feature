Feature: User accepts invitation

  Background:
    Given the following demos exist:
      | company_name | custom_welcome_message                              | seed_points |
      | FooCo        | You, %{unique_id}, are in the %{company_name} game. | 10          |
    And the following users exist:
      | email            | name | demo                |
      | dan@example.com  | Dan  | company name: 3M    |
      | phil@example.com | Phil | company_name: FooCo |
    And "dan@example.com" has received an invitation
    And "Dan" has the SMS slug "dan4444"
    And "phil@example.com" has received an invitation
    When "dan@example.com" opens the email
    And I click the first link in the email

  Scenario: User accepts invitation
    Then I should be on the invitation page for "dan@example.com"
    And I should see "Dan"
    When I fill in "Enter your mobile number" with "508-740-7520"
    And I fill in "Choose a password" with "whatwhat"
    And I fill in "And confirm that password" with "whatwhat"
    And I press "Join the game"
    And DJ cranks once
    Then "+15087407520" should have received an SMS "You've joined the 3M game! Your user ID is dan4444 (text MYID if you forget). To play, text to this #."
    And I should be on the activity page
    And I should see "Dan joined the game"

  Scenario: User accepting invitation shows on profile page as joining the game
    When I fill in "Enter your mobile number" with "508-740-7520"
    And I fill in "Choose a password" with "whatwhat"
    And I fill in "And confirm that password" with "whatwhat"
    And I press "Join the game"
    And I go to the profile page for "Dan"
    Then I should see "Dan joined the game"

  Scenario: User accepts invitation to game with a custom message
    When "phil@example.com" opens the email
    And I click the first link in the email
    And I fill in "Enter your mobile number" with "415-261-3077"
    And I fill in "Choose a password" with "whowho"
    And I fill in "And confirm that password" with "whowho"
    And I press "Join the game"
    And DJ cranks 5 times
    Then "+14152613077" should have received an SMS "You, pphil, are in the FooCo game."

  Scenario: User accepts invitation to game with seed points
    Given time is frozen
    When "phil@example.com" opens the email
    And I click the first link in the email
    And I fill in "Enter your mobile number" with "415-261-3077"
    And I fill in "Choose a password" with "whowho"
    And I fill in "And confirm that password" with "whowho"
    And I press "Join the game"
    Then I should be on the activity page
    And I should see "Phil 10 pts"
    And I should see "10 pts Phil joined the game less than a minute ago"

  Scenario: User doesn't get seed points twice
    Given time is frozen
    When "phil@example.com" opens the email
    And I click the first link in the email
    And I fill in "Enter your mobile number" with "415-261-3077"
    And I fill in "Choose a password" with "whowho"
    And I fill in "And confirm that password" with "whowho"
    And I press "Join the game"
    And I click the first link in the email
    And I fill in "Enter your mobile number" with "415-261-3077"
    And I fill in "Choose a password" with "whowho"
    And I fill in "And confirm that password" with "whowho"
    And I press "Join the game"
    Then I should be on the activity page
    And I should not see "Phil 20 points"

  Scenario: User sets password when accepting invitation
    When I fill in "Enter your mobile number" with "508-740-7520"
    And I fill in "Choose a password" with "whatwhat"
    And I fill in "And confirm that password" with "whatwhat"
    And I press "Join the game"
    And I sign out
    And I sign in via the login page as "Dan/whatwhat"
    And I should not see "Signed in."
    But I should be on the activity page

  Scenario: User must set password when accepting invitation
    When I fill in "Enter your mobile number" with "508-740-7520"
    And I press "Join the game"
    Then I should be on the invitation page for "dan@example.com"
    And I should not see "You're now signed in."
    And I should see "Please choose a password."
