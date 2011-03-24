Feature: User can follow another user by SMS

  Background:
    Given the following users exist:
      | name        | phone number |
      | Dan Croak   | +16175551212 |
      | Vlad Gyster | +16178675309 |
    And "Dan Croak" has the SMS slug "dan4444"

  Scenario: User follows another by SMS
    When "+16178675309" sends SMS "follow dan4444"
    And I sign in via the login page
    And I go to the profile page for "Dan Croak"
    Then I should see "1 followers"
    And "+16178675309" should have received an SMS "OK, you're now following Dan Croak."

  Scenario: User tries to follow the same user twice
    When "+16178675309" sends SMS "follow dan4444"
    And "+16178675309" sends SMS "follow dan4444"
    And I sign in via the login page
    And I go to the profile page for "Vlad Gyster"
    Then I should see "1 following"
    And "+16178675309" should have received an SMS "You're already following Dan Croak."

  Scenario: User tries to follow another user who doesn't exist
    When "+16178675309" sends SMS "follow mrnobody"
    And I sign in via the login page
    And I go to the profile page for "Vlad Gyster"
    Then I should see "0 following"
    And "+16178675309" should have received an SMS "Sorry, we couldn't find a user with the unique ID mrnobody."

  Scenario: Request to follow from a user who isn't registered
    When "+18085551212" sends SMS "follow dan4444"
    Then "+18085551212" should have received an SMS 'I can't find your number in my records. Did you claim your account yet? If not, text your first initial and last name (if you are John Smith, text "jsmith").'

  Scenario: "Connect" should be a synonym for "follow"
    When "+16178675309" sends SMS "connect dan4444"
    And I sign in via the login page
    And I go to the profile page for "Dan Croak"
    Then I should see "1 followers"
    And "+16178675309" should have received an SMS "OK, you're now following Dan Croak."
