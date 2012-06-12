Feature: User claims account via SMS

  Background:
    Given the following user exists:
      | name | privacy level | demo                     |
      | Bob  | everybody     | name: Global Tetrahedron |
    And "Bob" has the password "blehblah"

  Scenario: User claims account with claim code
    Given the following user exists:
      | name      | claim_code | privacy level | demo                             |
      | Dan Croak | dcroak     | everybody     | name: Global Tetrahedron         |
    And "Dan Croak" has the SMS slug "dcroak4444"
    When "+14155551212" sends SMS "Dcroak"
    Then "Dan Croak" should be claimed by "+14155551212"
    And "+14155551212" should have received an SMS "You've joined the Global Tetrahedron game! Your username is dcroak4444 (text MYID if you forget). To play, text to this #."


  Scenario: Claiming account sends user a password reset email
    Given the following user exists:
      | name      | email           | claim_code | demo                             |
      | Dan Croak | dan@example.com | dcroak     | name: Global Tetrahedron |
    When "+14155551212" sends SMS "Dcroak"
    Then "Dan Croak" should have a null password

    When DJ cranks 5 times after a little while
    And "dan@example.com" opens the email
    Then I should see "Set your password" in the email subject
    And I should not see "Someone, hopefully you, has requested that we send you a link to change your password." in the email body

    And I click the reset password link in the email
    And I fill in "Password" with "dandan"
    And I fill in "Confirm password" with "dandan"
    And I press "Save this password"
    Then I should be on the activity page

    When I sign out
    And I sign in via the login page with "Dan Croak/dandan"
    Then I should be on the activity page with HTML forced

  Scenario: Claiming account shows in activity stream as joining the game
    Given the following user exists:
      | name      | claim_code | privacy level | demo                             |
      | Dan Croak | dcroak     | everybody     | name: Global Tetrahedron         |
    When "+14155551212" sends SMS "Dcroak"
    And I sign in via the login page as "Bob/blehblah"
    Then I should see "Dan Croak joined the game"

  Scenario: Claiming account shows on profile page as joining the game
    Given the following user exists:
      | name      | claim_code | privacy level | demo                             |
      | Dan Croak | dcroak     | everybody     | name: Global Tetrahedron         |
    When "+14155551212" sends SMS "Dcroak"
    And I sign in via the login page as "Bob/blehblah"
    And I go to the profile page for "Dan Croak"
    Then I should see "Dan Croak joined the game"

  Scenario: User claims account for demo with custom welcome message
    Given the following demo exists:
      | name | custom_welcome_message    |
      | FooCo        | Let's play a game.        |
    And the following user exists:
      | name      | claim_code | demo                |
      | Dan Croak | dcroak     | name: FooCo |
    When "+14155551212" sends SMS "Dcroak"
    Then "+14155551212" should have received an SMS "Let's play a game."

  Scenario: User claims account for demo with seed points
    Given the following demo exists:
      | name  | seed_points |
      | FooCo | 10          |
    And time is frozen
    And the following user exists:
      | name      | claim_code | privacy level | demo                |
      | Dan Croak | dcroak     | everybody     | name: FooCo         |
    And the following user exists:
      | name | demo                |
      | Fred | name: FooCo |
    And "Fred" has the password "ferdinand"
    When "+14155551212" sends SMS "Dcroak"
    And I sign in via the login page as "Fred/ferdinand"
    # Then I should see "Dan Croak 10 pts"
    And I should see "10 pts Dan Croak joined the game less than a minute ago"


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
      | name       | claim code | privacy level | demo                             |
      | John Smith | jsmith     | everybody     | name: Global Tetrahedron         |
      | Jack Smith | jsmith     | everybody     | name: Global Tetrahedron         |
    When "+14155551212" sends SMS "john jsmith"
    And I sign in via the login page as "Bob/blehblah"
    Then I should see "John Smith joined the game"

  Scenario: User can't claim if their number is already assigned to an account
    Given the following users exist:
      | name            | claim_code  | email               | phone_number | accepted invitation at |
      | Phil Darnowsky  |             | phil@darnowsky.com  | +14152613077 | 2011-01-01 00:00:00    |
      | Paul Darnowsky  | pdarnowsky1 | paul@darnowsky.com  |              |                        |
      | Peter Darnowsky | pdarnowsky2 | peter@darnowsky.com |              |                        |
    When "+14152613077" sends SMS "pdarnowsky1"
    And "+14152613077" sends SMS "peter@darnowsky.com"
    Then "Paul Darnowsky" should not be claimed
    And "Peter Darnowsky" should not be claimed
    And "+14152613077" should have received an SMS "You've already claimed your account, and have 0 pts. If you're trying to credit another user, ask them to check their username with the MYID command."

  Scenario: If user claims twice, they get a helpful error message
    Given the following demo exists:
      | name | seed_points |
      | W00t!        | 5           |
    And the following user exists:
      | name            | claim_code  | demo                |
      | Phil Darnowsky  | pdarnowsky  | name: W00t! |
    And "Phil Darnowsky" has the SMS slug "pdarnowsky99"
    When "+14152613077" sends SMS "pdarnowsky"
    And "+14152613077" sends SMS "pdarnowsky"
    Then "+14152613077" should have received an SMS "You've joined the W00t! game! Your username is pdarnowsky99 (text MYID if you forget). To play, text to this #."
    And "+14152613077" should have received an SMS "You've already claimed your account, and have 5 pts. If you're trying to credit another user, ask them to check their username with the MYID command."

  Scenario: User can't claim account already claimed
    Given the following user with phone exists:
      | name | accepted_invitation_at | claim code |
      | Phil | 2011-01-01 00:00:00    | phil       |
    When "+14155551212" sends SMS "phil"
    Then "+14155551212" should have received an SMS 'That ID "phil" is already taken. If you're trying to register your account, please text in your own ID first by itself.'
      
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
      | name | phone number | unrecognized user message |
      | CustomOne    | +19005551212 |                           |
      | CustomTwo    | +19765551212 | Go screw, luser           |
    And "+14155551212" sends SMS "nobody" to "+19005551212"
    And "+16175551212" sends SMS "nobody" to "+19765551212"
    Then "+14155551212" should have received an SMS `I can't find your number in my records. Did you claim your account yet? If not, text your first initial and last name (if you are John Smith, text "jsmith").`
    And "+16175551212" should have received an SMS "Go screw, luser"
