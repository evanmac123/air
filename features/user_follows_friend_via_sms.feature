Feature: User can follow another user by SMS

  Background:
    Given the following demos exist:
      | name     | phone number |
      | Yoyodyne | +12155551212 |
      | BigCorp  | +19085551212 |
    Given the following claimed users exist:
      | name        | phone number | demo           | privacy level | notification_method |
      | Dan Croak   | +16175551212 | name: Yoyodyne | everybody     | both                |
      | Vlad Gyster | +16178675309 | name: Yoyodyne | everybody     | both                |
      | John Smith  | +12125551212 | name: BigCorp  | everybody     | both                |
    And the following user exist:
      | name        | phone number | demo           | notification_method |
      | Joe Bob     |              | name: Yoyodyne | both                |
    And "Vlad Gyster" has password "foobar"

  Scenario: User follows another by SMS
    When "+16178675309" sends SMS "follow dancroak"
    And "+16175551212" sends SMS "yes"
    And I sign in via the login page with "Vlad Gyster/foobar"
    And I go to the profile page for "Dan Croak"
    Then I should see "with Vlad Gyster"
    And "+16178675309" should have received an SMS "OK, you'll be friends with Dan Croak, pending their acceptance."

  Scenario: User tries to follow the same user twice
    When "+16178675309" sends SMS "follow dancroak"
    And "+16175551212" sends SMS "yes"
    And "+16178675309" sends SMS "follow dancroak"
    And I sign in via the login page with "Vlad Gyster/foobar"
    And I go to the profile page for "Vlad Gyster"
    Then I should see "is now friends with Dan Croak"
    And "+16178675309" should have received an SMS "You're already friends with Dan Croak."

  Scenario: User tries to follow another twice while the first request is pending
    When "+16178675309" sends SMS "follow dancroak"
    And "+16178675309" sends SMS "follow dancroak"
    And I sign in via the login page with "Vlad Gyster/foobar"
    And I go to the profile page for "Vlad Gyster"
    Then I should see "No friends yet"
    And "+16178675309" should have received an SMS "You've already asked to be friends with Dan Croak."
    
  Scenario: User tries to follow another user who doesn't exist
    When "+16178675309" sends SMS "follow mrnobody"
    And I sign in via the login page with "Vlad Gyster/foobar"
    And I go to the profile page for "Vlad Gyster"
    Then I should see "No friends yet"
    And "+16178675309" should have received an SMS "Sorry, we couldn't find a user with the username mrnobody."

  Scenario: User tries to follow another user in a different demo
    When "+16178675309" sends SMS "follow johnsmith"
    And I sign in via the login page with "Vlad Gyster/foobar"
    And I go to the profile page for "Vlad Gyster"
    Then I should see "No friends yet"
    And "+16178675309" should have received an SMS "Sorry, we couldn't find a user with the username johnsmith."

  Scenario: User tries to friend themselves
    When "+16178675309" sends SMS "follow vladgyster"
    And DJ works off
    Then "+16178675309" should not have received an SMS including "fan of Vlad Gyster, pending their acceptance"
    And "+16178675309" should not have received an SMS including "Vlad Gyster has asked to be your friend"
    And "+16178675309" should have received an SMS "Sorry, you can't add yourself as a friend."
  
  Scenario: Request to follow a user who hasn't claimed their account
    When "+16178675309" sends SMS "follow joebob"
    And I sign in via the login page with "Vlad Gyster/foobar"
    And I go to the profile page for "Vlad Gyster"
    Then I should see "No friends yet"
    And "+16178675309" should have received an SMS "Sorry, we couldn't find a user with the username joebob."

  Scenario: Request to follow from a user who isn't registered
    When "+18085551212" sends SMS "follow dancroak" to "+12155551212"
    Then "+18085551212" should have received an SMS 'I can't find you in my records. Did you claim your account yet? If not, send your first initial and last name (if you are John Smith, send "jsmith").'

  Scenario: "Connect" should be a synonym for "follow"
    When "+16178675309" sends SMS "connect dancroak"
    And "+16175551212" sends SMS "yes"
    And DJ works off
    And I sign in via the login page as "Vlad Gyster/foobar"
    And I go to the profile page for "Dan Croak"
    # Then I should see "has 1 fan"
    And "+16178675309" should have received an SMS "Dan Croak has approved your friendship request."
