Feature: User accepts invitation

  Scenario: User accepts invitation
    Given the following users exist:
      | email           | name | demo             |
      | dan@example.com | Dan  | company name: 3M |
    And "dan@example.com" has received an invitation
    When "dan@example.com" opens the email
    And I click the first link in the email
    Then I should be on the invitation page for "dan@example.com"
    And I should see "Dan"
    When I fill in "Enter your mobile number" with "508-740-7520"
    And I press "Join the game"
    Then "+15087407520" should have received an SMS "You've joined the 3M game! To play, send texts to this number. Send a text HELP if you want help."
    And I should be on the activity page

  Scenario: User claims account
    Given the following user exists:
      | name | claim_code | demo                               |
      | Dan  | croaky23   | company_name: Global Tetrahedron |
    When "+14155551212" sends SMS "croaky23"
    Then "Dan" should be claimed by "+14155551212"
    And "+14155551212" should have received an SMS "Welcome to the Global Tetrahedron game!"
