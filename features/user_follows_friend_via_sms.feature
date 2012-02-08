Feature: User can follow another user by SMS

  Background:
    Given the following claimed users exist:
      | name        | phone number | demo                   |
      | Dan Croak   | +16175551212 | name: Yoyodyne |
      | Vlad Gyster | +16178675309 | name: Yoyodyne |
      | John Smith  | +12125551212 | name: BigCorp  |
    And the following users exist:
      | name        | phone number | demo                   |
      | Joe Bob     |              | name: Yoyodyne |


  Scenario: User follows another by SMS
    When I need to hook this up
    When "+16178675309" sends SMS "follow dancroak"
    And "+16175551212" sends SMS "yes"
    And I sign in via the login page
    And I go to the profile page for "Dan Croak"
    Then I should see "has 1 fan"
    And "+16178675309" should have received an SMS "OK, you'll be a fan of Dan Croak, pending their acceptance."

  Scenario: User tries to follow the same user twice
    When I need to hook this up
    When "+16178675309" sends SMS "follow dancroak"
    And "+16175551212" sends SMS "yes"
    And "+16178675309" sends SMS "follow dancroak"
    And I sign in via the login page
    And I go to the profile page for "Vlad Gyster"
    Then I should see "fan of 1 person"
    And "+16178675309" should have received an SMS "You're already a fan of Dan Croak."

  Scenario: User tries to follow another twice while the first request is pending
    When I need to hook this up
    When "+16178675309" sends SMS "follow dancroak"
    And "+16178675309" sends SMS "follow dancroak"
    And I sign in via the login page
    And I go to the profile page for "Vlad Gyster"
    Then I should see "fan of 0 people"
    And "+16178675309" should have received an SMS "You've already asked to be a fan of Dan Croak."
    
  Scenario: User tries to follow another user who doesn't exist
    When I need to hook this up
    When "+16178675309" sends SMS "follow mrnobody"
    And I sign in via the login page
    And I go to the profile page for "Vlad Gyster"
    Then I should see "fan of 0 people"
    And "+16178675309" should have received an SMS "Sorry, we couldn't find a user with the username mrnobody."

  Scenario: User tries to follow another user in a different demo
    When I need to hook this up
    When "+16178675309" sends SMS "follow johnsmith"
    And I sign in via the login page
    And I go to the profile page for "Vlad Gyster"
    Then I should see "fan of 0 people"
    And "+16178675309" should have received an SMS "Sorry, we couldn't find a user with the username johnsmith."

  Scenario: User tries to follow themselves
    When "+16178675309" sends SMS "follow vladgyster"
    And DJ cranks 5 times
    Then "+16178675309" should not have received an SMS including "fan of Vlad Gyster, pending their acceptance"
    And "+16178675309" should not have received an SMS including "Vlad Gyster has asked to be your fan"
    And "+16178675309" should have received an SMS "Sorry, you can't follow yourself."
  
  Scenario: Request to follow a user who hasn't claimed their account
    When I need to hook this up
    When "+16178675309" sends SMS "follow joebob"
    And I sign in via the login page
    And I go to the profile page for "Vlad Gyster"
    Then I should see "fan of 0 people"
    And "+16178675309" should have received an SMS "Sorry, we couldn't find a user with the username joebob."

  Scenario: Request to follow from a user who isn't registered
    When "+18085551212" sends SMS "follow dancroak"
    Then "+18085551212" should have received an SMS 'I can't find your number in my records. Did you claim your account yet? If not, text your first initial and last name (if you are John Smith, text "jsmith").'

  Scenario: "Connect" should be a synonym for "follow"
    When "+16178675309" sends SMS "connect dancroak"
    And "+16175551212" sends SMS "yes"
    And DJ cranks 10 times
    And I sign in via the login page
    And I go to the profile page for "Dan Croak"
    Then I should see "has 1 fan"
    And "+16178675309" should have received an SMS "Dan Croak has approved your request to be a fan."
