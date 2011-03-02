Feature: User claims account via SMS

  Scenario: User claims account with claim code
    Given the following user exists:
      | name      | claim_code | demo                             |
      | Dan Croak | dcroak     | company_name: Global Tetrahedron |
    When "+14155551212" sends SMS "Dcroak"
    Then "Dan Croak" should be claimed by "+14155551212"
    And "+14155551212" should have received an SMS "You've joined the Global Tetrahedron game! To play, send texts to this number. Send a text HELP if you want help."

  Scenario: Claiming account sets password so user can log in via Web
    Given the following user exists:
      | name      | claim_code | demo                             |
      | Dan Croak | dcroak     | company_name: Global Tetrahedron |
    When "+14155551212" sends SMS "Dcroak"
    And I sign in via the login page as "Dan Croak/dcroak"
    Then I should see "Signed in"

  Scenario: Claiming account show in activity stream as joining the game
    Given the following user exists:
      | name      | claim_code | demo                             |
      | Dan Croak | dcroak     | company_name: Global Tetrahedron |
    When "+14155551212" sends SMS "Dcroak"
    And I sign in via the login page as "Dan Croak/dcroak"
    Then I should see "Dan Croak joined the game"

  Scenario: User claims account for demo with custom welcome message
    Given the following demo exists:
      | company_name | custom_welcome_message    |
      | FooCo        | Let's play a game.        |
    And the following user exists:
      | name      | claim_code | demo                |
      | Dan Croak | dcroak     | company_name: FooCo |
    When "+14155551212" sends SMS "Dcroak"
    Then "+14155551212" should have received an SMS "Let's play a game."

  Scenario: User claims account for demo with seed points
    Given the following demo exists:
      | company_name | seed_points |
      | FooCo        | 10          |
    And the following user exists:
      | name      | claim_code | demo                |
      | Dan Croak | dcroak     | company_name: FooCo |
    When "+14155551212" sends SMS "Dcroak"
    And I sign in via the login page as "Dan Croak/dcroak"
    Then I should see "Dan Croak 10 points"

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

  Scenario: User can't claim if their number is already assigned to an account
    Given the following users exist:
      | name            | claim_code  | email               | phone_number |
      | Phil Darnowsky  |             | phil@darnowsky.com  | +14152613077 |
      | Paul Darnowsky  | pdarnowsky1 | paul@darnowsky.com  |              |
      | Peter Darnowsky | pdarnowsky2 | peter@darnowsky.com |              |
    When "+14152613077" sends SMS "pdarnowsky1"
    And "+14152613077" sends SMS "peter@darnowsky.com"
    Then "Paul Darnowsky" should not be claimed
    And "Peter Darnowsky" should not be claimed
