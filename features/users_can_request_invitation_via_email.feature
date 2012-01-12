Feature: Users can request invitation via email

  Background: 
    Given the following self inviting domain exists:
      | domain   |
      | join.com |
  Scenario:
    When "alpha@join.com" sends email with subject "I Tarzan, You Jane" and body "join"
    Then "alpha@join.com" should receive an email
    When "alpha@join.com" opens the email
    And I click the first link in the email
    Then I should be on the invitation page for "alpha@join.com"