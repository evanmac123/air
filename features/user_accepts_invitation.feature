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

  Scenario: User claims account with claim code
    Given the following user exists:
      | name      | claim_code | demo                               |
      | Dan Croak | dcroak     | company_name: Global Tetrahedron   |
    When "+14155551212" sends SMS "Dcroak"
    Then "Dan Croak" should be claimed by "+14155551212"
    And "+14155551212" should have received an SMS "Welcome to the Global Tetrahedron game!"

  Scenario: User claims account with e-mail address (but only if they've got a claim code)
    Given the following users exist:
      | name       | email              |
      | Dan Croak  | dan@example.com    |
      | John Smith | jsmith@example.com |
    And "Dan Croak" has a claim code
    When "+14155551212" sends SMS "dan@example.com"
    And "+16175551212" sends SMS "jsmith@example.com"
    Then "Dan Croak" should be claimed by "+14155551212"
    And "John Smith" should not be claimed

  Scenario: Ambiguous claim code
    Given the following users exist:
      | name       | claim_code |
      | John Smith | jsmith     |
      | Jack Smith | jsmith     |
    When "+14155551212" sends SMS "jsmith"
    Then "John Smith" should not be claimed
    And "Jack Smith" should not be claimed
    And "+14155551212" should have received an SMS "We found multiple people with your first initial and last name. Please try sending us your e-mail address instead."


