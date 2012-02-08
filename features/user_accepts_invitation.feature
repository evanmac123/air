
Feature: User accepts invitation

  Background:
    Given the following demos exist:
      | name | custom_welcome_message                              | seed_points |
      | FooCo        | You, %{unique_id}, are in the %{name} game. | 10          |
    And the following users exist:
      | email            | name | demo                |
      | dan@example.com  | Dan  | name: 3M            |
      | phil@example.com | Phil | name: FooCo         |
    And "dan@example.com" has received an invitation
    And "phil@example.com" has received an invitation
    When "dan@example.com" opens the email
    And I click the first link in the email

  Scenario: Throws error messages if terms and conditions not accepted
    Then I should be on the invitation page for "dan@example.com"
    When I fill in "Enter your mobile number" with "508-740-7520"
    And I fill in "Choose a password" with "whatwhat"
    And I fill in "And confirm that password" with "whatwhat"
    And I press "Join the game"
    And I should see "You must accept the terms and conditions"
    
  Scenario: User accepts invitation
    Then I should be on the invitation page for "dan@example.com"
    When I fill in "Enter your mobile number" with "508-740-7520"
    And I fill in "Choose a password" with "whatwhat"
    And I fill in "And confirm that password" with "whatwhat"
    And I check "Terms and conditions"
    And I press "Join the game"
    Then I should be on the interstitial phone verification page

    When DJ cranks 5 times
    Then "Dan" should receive an SMS containing their new phone validation code
    When "Dan" fills in the new phone validation field with their validation code
    And I press "Validate phone"
    And DJ cranks 5 times

    Then "+15087407520" should have received an SMS "You've joined the 3M game! Your username is dan (text MYID if you forget). To play, text to this #."
    And I should be on the activity page
    And I should see "Dan joined the game"

  Scenario: User accepting invitation without a phone number does not go through the phone number validation page
    When I fill in "Choose a password" with "whatwhat"
    And I fill in "And confirm that password" with "whatwhat"
    And I check "Terms and conditions"
    And I press "Join the game"
    Then I should be on the activity page

  Scenario: User accepting invitation who has trouble validating phone number gets redirected to the validation page with an appropriate error
    When I fill in "Enter your mobile number" with "508-740-7520"
    And I fill in "Choose a password" with "whatwhat"
    And I fill in "And confirm that password" with "whatwhat"
    And I check "Terms and conditions"
    And I press "Join the game"
    Then I should be on the interstitial phone validation page
    
    When "Dan" fills in the new phone validation field with the wrong validation code
    And I press "Validate phone"
    Then I should be on the interstitial phone validation page
    And I should see "Sorry, the code you entered was invalid. Please try typing it again."


  Scenario: User accepting invitation shows on profile page as joining the game
    When I fill in "Enter your mobile number" with "508-740-7520"
    And I fill in "Choose a password" with "whatwhat"
    And I fill in "And confirm that password" with "whatwhat"
    And I check "Terms and conditions"
    And I press "Join the game"
    And I go to the profile page for "Dan"
    Then I should see "Dan joined the game"

  Scenario: User accepts invitation to game with a custom message
    When "phil@example.com" opens the email
    And I click the first link in the email
    And I fill in "Enter your mobile number" with "415-261-3077"
    And I fill in "Choose a password" with "whowho"
    And I fill in "And confirm that password" with "whowho"
    And I check "Terms and conditions"
    And I press "Join the game"
    And "Phil" fills in the new phone validation field with their validation code
    And I press "Validate phone"
    And DJ cranks 5 times
    
    Then "+14152613077" should have received an SMS "You, phil, are in the FooCo game."

  Scenario: User accepts invitation to game with seed points
    Given time is frozen
    When "phil@example.com" opens the email
    And I click the first link in the email
    And I fill in "Enter your mobile number" with "415-261-3077"
    And I fill in "Choose a password" with "whowho"
    And I fill in "And confirm that password" with "whowho"
    And I check "Terms and conditions"
    And I press "Join the game"
    And I follow "Confirm my mobile number later"
    Then I should be on the activity page
    # And I should see "Phil 10 pts"
    And I should see "10 pts Phil joined the game less than a minute ago"

  Scenario: User doesn not get seed points twice
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
    And I check "Terms and conditions"
    And I press "Join the game"
    Then I should be on the activity page
    And I should not see "Phil 20 points"

  Scenario: User sets password when accepting invitation
    When I fill in "Enter your mobile number" with "508-740-7520"
    And I fill in "Choose a password" with "whatwhat"
    And I fill in "And confirm that password" with "whatwhat"
    And I check "Terms and conditions"
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

  Scenario: User doesn not have to specify mobile number to join
    When I fill in "Choose a password" with "whatwhat"
    And I fill in "And confirm that password" with "whatwhat"
    And I check "Terms and conditions"
    And I press "Join the game"
    And DJ cranks once
    Then I should be on the activity page
    And I should see "Dan joined the game less than a minute ago"

  Scenario: User accepts invitation before game begins
    Given the following demo exists:
      | name | begins_at                 |
      | LateCo       | 2011-05-01 00:00:00 -0400 |
    And time is frozen at "2011-01-01 00:00:00 -0400"
    And the following users exist:
      | name | email          | demo                 |
      | Joe  | joe@lateco.com | name: LateCo |
    And "joe@lateco.com" has received an invitation
    When "joe@lateco.com" opens the email
    And I click the first link in the email

    When I fill in "Enter your mobile number" with "508-740-7520"
    And I fill in "Choose a password" with "whatwhat"
    And I fill in "And confirm that password" with "whatwhat"
    And I check "Terms and conditions"
    And I press "Join the game"

    Then I should be on the interstitial phone verification page
    And I should not see "Your game begins on May 01, 2011 at 12:00 AM Eastern."
    When "Joe" fills in the new phone validation field with their validation code
    And I press "Validate phone"

    Then I should be on the activity page
    And I should see "Your game begins on May 01, 2011 at 12:00 AM Eastern."
    But "Joe" should be claimed by "+15087407520"

    When I go to the activity page
    Then I should see "Your game begins on May 01, 2011 at 12:00 AM Eastern."
    
  Scenario: User accepts invitation for demo with no locations, and does not see dropdown for it
    When I click the first link in the email
    Then I should be on the invitation page for "dan@example.com"
    And I should not see "Location"

  Scenario: User can set username when accepting invitation
    When I click the first link in the email
    And I fill in "Choose a username" with "phil"
    And I fill in "Enter your mobile number" with "508-740-7520"
    And I fill in "Choose a password" with "whatwhat"
    And I fill in "And confirm that password" with "whatwhat"
    And I check "Terms and conditions"
    And I press "Join the game"
    Then I should not see "Welcome to the game"
    And I should see "Sorry, that username is already taken."
    
    When I fill in "Choose a username" with "         "
    And I press "Join the game"
    Then I should not see "Welcome to the game"
    And I should see "Please choose a username"

    When I fill in "Choose a username" with "i rule"
    And I press "Join the game"
    
    Then I should not see "Welcome to the game"
    
    And I should see "Sorry, the username must consist of letters or digits only."

    When I fill in "Choose a username" with "DannyBoy"
    And I check "Terms and conditions"
    And I press "Join the game"
    When "Dan" fills in the new phone validation field with their validation code
    And I press "Validate phone"
    Then I should be on the activity page

    When DJ cranks 5 times
    Then "+15087407520" should have received an SMS including "dannyboy"

  Scenario: User is not logged until she actually accepts the invitation (and can abandon it and come back later)
    When I fill in "Enter your mobile number" with "508-740-7520"
    And I fill in "Choose a password" with "whatwhat"
    And I fill in "And confirm that password" with "whatwhat"
    And I check "Terms and conditions"
    ### This is where I abandon my invitation acceptance page and go somewhere else #######################
    And I go to the home page
    ### This is where I come back to the invitation acceptance page at some point (still not accepted)#####
    When I click the first link in the email
    Then I should be on the invitation page for "dan@example.com"
    When I fill in "Enter your mobile number" with "508-740-7520"
    And I fill in "Choose a password" with "whatwhat"
    And I fill in "And confirm that password" with "whatwhat"
    And I check "Terms and conditions"
    And I press "Join the game"
    Then I should be on the interstitial phone verification page
    When I click the first link in the email
    Then I should be on the activity page
    And I should see "You've already accepted your invitation to the game."

    When I sign out
    And I click the first link in the email
    Then I should be on the signin page
    And I should see "You've already accepted your invitation to the game. Please log in if you'd like to use the site."

  Scenario: User doesn't see Highmark-specific copy
    Then I should not see "Neither Highmark, its subsidiaries or agents, will be held responsible for any charges related to the use of the services."
