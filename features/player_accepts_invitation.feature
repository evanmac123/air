Feature: Player accepts invitation

  Scenario: Player accepts invitation
    Given the following player exists:
      | email           | name | demo             |
      | dan@example.com | Dan  | company name: 3M |
    And "dan@example.com" has received an invitation
    When "dan@example.com" opens the email
    And I click the first link in the email
    Then I should be on the invitation page for "dan@example.com"
    And I should see "Dan"
    When I fill in "Enter your mobile number" with "508-740-7520"
    And I press "Submit"
    Then "+5087407520" should have received an SMS "You've joined the 3M game!"
