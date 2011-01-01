Feature: Player accepts invite

  Scenario: Player accepts invite
    Given the following player exists:
      | email           | name |
      | dan@example.com | Dan  |
    And "dan@example.com" has received an invitation
    When "dan@example.com" opens the email
    And I click the first link in the email
    Then I should be on the invitation page for "dan@example.com"
    And I should see "Dan"
    When I fill in "Enter your mobile number" with "508-740-7520"
    Then Twilio should send an SMS to "+5087407520"
