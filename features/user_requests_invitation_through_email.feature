Feature: Users can request invitation via email

  Background: 
    Given the following self inviting domain exists:
      | domain     | demo         |
      | join.com   | name: JoinCo |
    Given the following claimed users exist:
      | email           | demo           | 
      | yep@join.com    | name: JoinCo   |
      | nope@nojoin.com | name: NoJoinCo |
    And the following users exist:
      | email        | demo         |
      | joe@join.com | name: JoinCo |
      | bob@join.com | name: JoinCo |

  Scenario: User requests invitation via email
    When "alpha@join.com" sends email with subject "I Tarzan, You Jane" and body "join"
    And DJ cranks 5 times
    Then "alpha@join.com" should receive an email
    When "alpha@join.com" opens the email
    And I click the play now button in the email
    Then I should be on the invitation page for "alpha@join.com"
    And I should see "Your Email Address:"
    And I should not see "Enter your email address"
    And I should see "Enter your mobile number"
    And I should see "Welcome to H Engage"
    When I fill in "Enter your mobile number" with "(208) 366-6066"
    And I fill in "Enter your name" with "Josh Groban"
    And I fill in "Choose a username" with "joshy"
    And I fill in "Choose a password" with "abcdefg"
    And I fill in "And confirm that password" with "abcdefg"
    And I check "Terms and conditions"
    And I press "Join the game"
    And I follow "Confirm my mobile number later"
    Then I should be on the activity page
    
  Scenario: A join email that is not from aself-inviting domain doesn't get an invitation
    When "nope@alabaster.com" sends email with subject "join" and body "I Tarzan, You Jane"
    And DJ cranks 5 times
    Then "nope@alabaster.com" should receive an email
    When "nope@alabaster.com" opens the email
    Then I should see "The domain 'alabaster.com' is not valid for this game" in the email body
 
  Scenario: A join email from an existing claimed user in a demo with no self-inviting domain gives a reasonable error
    When "nope@nojoin.com" sends email with subject "I Tarzan, You Jane" and body "join"
    And DJ cranks 5 times

    Then "nope@nojoin.com" should receive an email
    When "nope@nojoin.com" opens the email
    Then I should see "It looks like you are already registered" in the email body
  
  Scenario: Any email from a self-inviting domain that is not yet a user sends invitation
    When "beta@join.com" sends email with subject "I Tarzan, You Jane" and body "anything"
    And DJ cranks 5 times
    Then "beta@join.com" should receive an email
    When "beta@join.com" opens the email
    Then I should see "You’re invited..." in the email body
    
    When "alpha@join.com" sends email with subject "I Tarzan, You Jane" and body "join"
    Then "alpha@join.com" should receive an email
    When "alpha@join.com" opens the email
    And I click the play now button in the email
    Then I should be on the invitation page for "alpha@join.com"

  Scenario: Unclaimed user requesting invitation via email gets treated as a request for invitation resend
    When "joe@join.com" sends email with subject "join" and body "I sure do love pickles"
    And DJ cranks 5 times
    Then "joe@join.com" should receive an email
    
    When "joe@join.com" opens the email
    And I click the play now button in the email
    Then I should be on the invitation page for "joe@join.com"
    
    When "bob@join.com" sends email with subject "lions and tigers and bears" and body "oh my"
    And DJ cranks 5 times
    Then "bob@join.com" should receive an email

    When "bob@join.com" opens the email
    And I click the play now button in the email
    Then I should be on the invitation page for "bob@join.com"
