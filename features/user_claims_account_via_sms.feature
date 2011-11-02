Feature: User claims account via SMS

  Background:
    Given the following user exists:
      | name | demo                             |
      | Bob  | company_name: Global Tetrahedron |
    And "Bob" has the password "bleh"

  Scenario: User claims account with claim code
    Given the following user exists:
      | name      | claim_code | demo                             |
      | Dan Croak | dcroak     | company_name: Global Tetrahedron |
    And "Dan Croak" has the SMS slug "dcroak4444"
    When "+14155551212" sends SMS "Dcroak"
    Then "Dan Croak" should be claimed by "+14155551212"
    And "+14155551212" should have received an SMS "You've joined the Global Tetrahedron game! Your user ID is dcroak4444 (text MYID if you forget). To play, text to this #."

  Scenario: Claiming account sends user a password reset email
    Given the following user exists:
      | name      | email           | claim_code | demo                             |
      | Dan Croak | dan@example.com | dcroak     | company_name: Global Tetrahedron |
    When "+14155551212" sends SMS "Dcroak"
    Then "Dan Croak" should have a null password

    When DJ cranks 5 times
    And "dan@example.com" opens the email
    Then I should see "Set your password" in the email subject
    And I should not see "Someone, hopefully you, has requested that we send you a link to change your password." in the email body

    And I click the first link in the email
    And I fill in "Choose password" with "dandan"
    And I fill in "Confirm password" with "dandan"
    And I press "Save this password"
    Then I should be on the activity page

    When I sign out
    And I sign in via the login page with "Dan Croak/dandan"
    Then I should be on the activity page

  Scenario: Claiming account shows in activity stream as joining the game
    Given the following user exists:
      | name      | claim_code | demo                             |
      | Dan Croak | dcroak     | company_name: Global Tetrahedron |
    When "+14155551212" sends SMS "Dcroak"
    And I sign in via the login page as "Bob/bleh"
    Then I should see "Dan Croak joined the game"

  Scenario: Claiming account shows on profile page as joining the game
    Given the following user exists:
      | name      | claim_code | demo                             |
      | Dan Croak | dcroak     | company_name: Global Tetrahedron |
    When "+14155551212" sends SMS "Dcroak"
    And I sign in via the login page as "Bob/bleh"
    And I go to the profile page for "Dan Croak"
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
    And time is frozen
    And the following user exists:
      | name      | claim_code | demo                |
      | Dan Croak | dcroak     | company_name: FooCo |
    And the following user exists:
      | name | demo                |
      | Fred | company_name: FooCo |
    And "Fred" has the password "ferd"
    When "+14155551212" sends SMS "Dcroak"
    And I sign in via the login page as "Fred/ferd"
    Then I should see "Dan Croak 10 pts"
    And I should see "10 pts Dan Croak joined the game less than a minute ago"

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
    And "+14155551212" should have received an SMS 'There's more than one person with that code. Please try sending us your first name along with the code (for example: John Smith enters "john jsmith").'

  Scenario: User claims ambiguous code with their first name
    Given the following users exist:
      | name       | claim code | demo                             |
      | John Smith | jsmith     | company_name: Global Tetrahedron |
      | Jack Smith | jsmith     | company_name: Global Tetrahedron |
    When "+14155551212" sends SMS "john jsmith"
    And I sign in via the login page as "Bob/bleh"
    Then I should see "John Smith joined the game"

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
    And "+14152613077" should have received an SMS "You've already claimed your account, and have 0 pts. If you're trying to credit another user, ask them to check their user ID with the MYID command."

  Scenario: If user claims twice, they get a helpful error message
    Given the following demo exists:
      | company_name | seed_points |
      | W00t!        | 5           |
    And the following user exists:
      | name            | claim_code  | demo                |
      | Phil Darnowsky  | pdarnowsky  | company_name: W00t! |
    And "Phil Darnowsky" has the SMS slug "pdarnowsky99"
    When "+14152613077" sends SMS "pdarnowsky"
    And "+14152613077" sends SMS "pdarnowsky"
    Then "+14152613077" should have received an SMS "You've joined the W00t! game! Your user ID is pdarnowsky99 (text MYID if you forget). To play, text to this #."
    And "+14152613077" should have received an SMS "You've already claimed your account, and have 5 pts. If you're trying to credit another user, ask them to check their user ID with the MYID command."

  Scenario: Account can't be claimed twice by changing the mobile number
    Given the following user exists:
      | name            | claim_code |
      | Phil Darnowsky  | pdarnowsky |  
    And "Phil Darnowsky" has the password "foo"
    When "+14155551212" sends SMS "pdarnowsky"
    And I sign in via the login page as "Phil Darnowsky/foo"
    And I go to the profile page for "Phil Darnowsky"
    And I fill in "Enter your new mobile number" with "+18085551212"
    And I press the button to submit the mobile number
    And "+16175551212" sends SMS "pdarnowsky"
    Then "+16175551212" should not have received an SMS including "Your user ID is pdarnowsky"

    When I go to the activity page
    Then I should see "joined the game" just once
  
  Scenario: Some variability allowed in how users send their claim codes
    Given the following users exist:
      | name           | claim code |
      | Phil Darnowsky | pdarnowsky |
      | Dan Croak      | dcroak     |
      | Vlad Gyster    | vgyster    |
      | Kelli Peterson | kpeterson  |
    When "+14152613077" sends SMS "p darnowsky"
    And "+16175551212" sends SMS "d. croak"
    And "+12125551212" sends SMS '"vgyster"'
    And "+18085551212" sends SMS "    K. Peterson       "
    Then "Phil Darnowsky" should be claimed by "+14152613077"
    And "Dan Croak" should be claimed by "+16175551212"
    And "Vlad Gyster" should be claimed by "+12125551212"
    And "Kelli Peterson" should be claimed by "+18085551212"

  Scenario: User tries to claim with nonexistent claim code
    When "+14155551212" sends SMS "nobody"
    Then "+14155551212" should have received an SMS 'I can't find your number in my records. Did you claim your account yet? If not, text your first initial and last name (if you are John Smith, text "jsmith").'

  Scenario: User tries to claim with nonexistent claim code to a custom phone number
    Given the following demos exist:
      | company name | phone number | unrecognized user message |
      | CustomOne    | +19005551212 |                           |
      | CustomTwo    | +19765551212 | Go screw, luser           |
    And "+14155551212" sends SMS "nobody" to "+19005551212"
    And "+16175551212" sends SMS "nobody" to "+19765551212"
    Then "+14155551212" should have received an SMS `I can't find your number in my records. Did you claim your account yet? If not, text your first initial and last name (if you are John Smith, text "jsmith").`
    And "+16175551212" should have received an SMS "Go screw, luser"
