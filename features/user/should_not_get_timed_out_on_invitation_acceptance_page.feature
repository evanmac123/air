Feature: User shouldn't get timed out on invitation acceptance page

  Background: 
    Given the following user exists
      | email           | 
      | bob@example.com |
  Scenario: User shouldn't get timed out on invitation acceptance page
    When I go to the join page
    And I fill in "Email" with "bob@example.com"
    And I press "Request invitation"
    And DJ cranks 5 times
    And "bob@example.com" opens the email
    And I click the play now button in the email

    And I fill in the required self-invitation fields
    And 10 minutes pass
    And I check "Terms and conditions"
    And I press "Log in"
    Then I should be on the activity page
    And I should not see "Your session has expired"
