Feature: User shouldn't get timed out on invitation acceptance page

  Scenario: User shouldn't get timed out on invitation acceptance page
    Given the following self inviting domain exists:
      | domain      |
      | example.com |
    When I go to the join page
    And I fill in "Email" with "bob@example.com"
    And I press "Request invitation"
    And DJ cranks 5 times
    And "bob@example.com" opens the email
    And I click the first link in the email

    And I fill in the required self-invitation fields
    And 10 minutes pass
    And I press "Join the game"
    Then I should be on the activity page
    And I should not see "Your session has expired"
