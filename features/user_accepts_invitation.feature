
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
    Then "+15087407520" should have received an SMS "You've joined the 3M game! Your user ID is dan (text MYID if you forget). To play, text to this #."
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
    
    Then "+14152613077" should have received an SMS "You, phil, are in the FooCo game."

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
    When I press "Join the game"
    Then I should not see "Welcome to the game"
    And I should see "Please choose a password"

    When I fill in "Choose a password" with "foo"
    And I fill in "And confirm that password" with "bar"
    And I press "Join the game"
    Then I should not see "Welcome to the game"
    And I should see "Password doesn't match confirmation"

  Scenario: User doesn't have to specify mobile number to join
    When I fill in "Choose a password" with "whatwhat"
    And I fill in "And confirm that password" with "whatwhat"
    And I press "Join the game"
    And DJ cranks once
    Then I should be on the activity page
    And I should see "Dan joined the game less than a minute ago"
    When I go to the profile page for "Dan"
    Then I should not see "() -"
    But I should see "No mobile number. Please enter one if you'd like to play using text messaging."

  Scenario: User accepts invitation before game begins
    Given the following demo exists:
      | company name | begins_at                 |
      | LateCo       | 2011-05-01 00:00:00 -0400 |
    And time is frozen at "2011-01-01 00:00:00 -0400"
    And the following users exist:
      | name | email          | demo                 |
      | Joe  | joe@lateco.com | company_name: LateCo |
    And "joe@lateco.com" has received an invitation
    When "joe@lateco.com" opens the email
    And I click the first link in the email

    When I fill in "Enter your mobile number" with "508-740-7520"
    And I fill in "Choose a password" with "whatwhat"
    And I fill in "And confirm that password" with "whatwhat"
    And I press "Join the game"
    And I should see "Your game begins on May 01, 2011 at 12:00 AM Eastern."
    But "Joe" should be claimed by "+15087407520"

    When I go to the activity page
    Then I should see "Your game begins on May 01, 2011 at 12:00 AM Eastern."
    
  Scenario: User accepts invitation for demo with no locations, and doesn't see dropdown for it
    When I click the first link in the email
    Then I should be on the invitation page for "dan@example.com"
    And I should not see "Location"

  Scenario: User can set unique ID when accepting invitation
    When I click the first link in the email
    And I fill in "Choose a unique ID" with "phil"
    And I fill in "Enter your mobile number" with "508-740-7520"
    And I fill in "Choose a password" with "whatwhat"
    And I fill in "And confirm that password" with "whatwhat"
    And I press "Join the game"
    Then I should not see "Welcome to the game"
    And I should see "Sorry, that user ID is already taken."
    
    When I fill in "Choose a unique ID" with "         "
    And I press "Join the game"
    Then I should not see "Welcome to the game"
    And I should see "Sorry, you can't choose a blank user ID."

    When I fill in "Choose a unique ID" with "i rule"
    And I press "Join the game"
    
    Then I should not see "Welcome to the game"
    
    And I should see "Sorry, the user ID must consist of letters or digits only."

    When I fill in "Choose a unique ID" with "DannyBoy"
    And I press "Join the game"
    Then I should see "Welcome to the game"
    When DJ cranks once
    Then "+15087407520" should have received an SMS including "dannyboy"

