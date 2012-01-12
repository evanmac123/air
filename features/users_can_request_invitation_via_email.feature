Feature: Users can request invitation via email

  Background: 
    Given the following self inviting domain exists:
      | domain   |
      | join.com |
    Given the following claimed users exist:
      | email              |
      | yep@join.com       |
  Scenario:
    When "alpha@join.com" sends email with subject "I Tarzan, You Jane" and body "join"
    Then "alpha@join.com" should receive an email
    When "alpha@join.com" opens the email
    And I click the first link in the email
    Then I should be on the invitation page for "alpha@join.com"
    And I should see "Your Email Address: alpha@join.com"
    And I should not see "Enter your email address"
    And I should see "Enter your mobile number"
    And I should see "Welcome to H Engage"
    When I fill in "Enter your mobile number" with "(208) 366-6066"
    And I fill in "Enter your name" with "Josh Groban"
    And I fill in "Choose a unique ID" with "joshy"
    And I fill in "Choose a password" with "abcd"
    And I fill in "And confirm that password" with "abcd"
    And I press "Join the game"
    Then I should see "Welcome to the game!"
    
  Scenario: A join email that is not from a self-inviting domain
    When "nope@alabaster.com" sends email with subject "I Tarzan, You Jane" and body "join"
    Then "nope@alabaster.com" should receive an email
    When "nope@alabaster.com" opens the email
    Then I should see "The domain 'alabaster.com' is not valid for this game" in the email body
    
  
  Scenario: A join email from an existing claimed user
    When "yep@join.com" sends email with subject "I Tarzan, You Jane" and body "join"
    Then "yep@join.com" should receive an email
    When "yep@join.com" opens the email
    Then I should see "It looks like you are already registered" in the email body
    
    
    
