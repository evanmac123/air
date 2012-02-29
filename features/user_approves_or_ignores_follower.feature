Feature: User approves or ignores follower

  # TODO: Fix this giant mess. Also the step definitions.

  Background:
    Given the following demo exists:
      | name |
      | FooCo        |
    And the following claimed users exist:
      | name  | email             | phone number | privacy level | demo        |
      | Alice | alice@example.com | +14155551212 | everybody     | name: FooCo |
      | Bob   | bob@example.com   | +16175551212 | everybody     | name: FooCo |
      | Clay  | clay@example.com  | +13055551212 | everybody     | name: FooCo |
      | Don   | don@example.com   | +18085551212 | everybody     | name: FooCo |
      | Ed    | ed@example.com    | +12125551212 | everybody     | name: FooCo |
    And "Bob" has password "fooble"
    And "Alice" has password "barley"
    And "Clay" has password "bazquux"

  Scenario: Follower follows by SMS, followed accepts via SMS
    When "Alice" requests to follow "Bob/fooble" by SMS
    Then "Bob/fooble" should be able to accept "Alice" by SMS

  Scenario: Follower follows by SMS, followed ignores via SMS
    When "Alice" requests to follow "Bob/fooble" by SMS
    Then "Bob/fooble" should be able to ignore "Alice" by SMS

#   Scenario: Follower follows by SMS, followed accepts via web
    # When "Alice" requests to follow "Bob/fooble" by SMS
    # And DJ cranks 5 times
    # Then "Bob/fooble" should be able to accept "Alice" by web

  # Scenario: Follower follows by SMS, followed ignores via web
    # When "Alice" requests to follow "Bob/fooble" by SMS
    # And DJ cranks 5 times
    # Then "Bob/fooble" should be able to ignore "Alice" by web

  @javascript
  Scenario: Follower follows by web, followed accepts via SMS
    When "Alice/barley" requests to follow "Bob/fooble" by web
    And DJ cranks 5 times
    Then "Bob/fooble" should be able to accept "Alice" by SMS

  @javascript
  Scenario: Follower follows by web, followed ignores via SMS
    When "Alice/barley" requests to follow "Bob/fooble" by web
    And DJ cranks 5 times
    Then "Bob/fooble" should be able to ignore "Alice" by SMS

  # @javascript
  # Scenario: Follower follows by web, followed accepts via web
    # When "Alice/barley" requests to follow "Bob/fooble" by web
    # Then "Bob/fooble" should be able to accept "Alice" by web

  # @javascript
  # Scenario: Follower follows by web, followed ignores via web
    # When "Alice/barley" requests to follow "Bob/fooble" by web
    # Then "Bob/fooble" should be able to ignore "Alice" by web

  Scenario: Followed attempts to accept or ignore someone who did not request to follow
    When "+16175551212" sends SMS "yes"
    Then "+16175551212" should have received an SMS "You have no pending requests from anyone to be a fan."
    When I clear all sent texts
    And "+16175551212" sends SMS "no"
    Then "+16175551212" should have received an SMS "You have no pending requests from anyone to be a fan."

    When I clear all sent texts
    And "+16175551212" sends SMS "yes 2"
    Then "+16175551212" should have received an SMS "You have no pending requests from anyone to be a fan."
    When I clear all sent texts
    And "+16175551212" sends SMS "no 2"
    Then "+16175551212" should have received an SMS "You have no pending requests from anyone to be a fan."

    When "+14155551212" sends SMS "follow bob"
    And "+13055551212" sends SMS "follow bob"
    And DJ cranks 5 times
    And "+16175551212" sends SMS "yes 3"
    Then "+16175551212" should have received an SMS "Looks like you already responded to that request, or didn't have a request with that number"
    When I clear all sent texts
    And "+16175551212" sends SMS "no 3"
    Then "+16175551212" should have received an SMS "Looks like you already responded to that request, or didn't have a request with that number"

#   Scenario: Followed attempts to accept/ignore someone by SMS, then by web, and we head off a race condition
    # When "Alice" requests to follow "Bob/fooble" by SMS
    # And I sign in via the login page with "Bob/fooble"
    # Then I should see "Alice" as a pending follower

    # When I go to the connections page
    # And "+16175551212" sends SMS "yes"
    # And I press the accept button
    # And DJ cranks 5 times
    # Then "+14155551212" should have received an SMS "Bob has approved your request to be a fan."
    # And "+16175551212" should have received an SMS "OK, Alice is now your fan."
    # And I should see "You've already accepted that person's request."

    # When "Clay" requests to follow "Bob/fooble" by SMS
    # And I sign in via the login page with "Bob/fooble"
    # Then I should see "Clay" as a pending follower
    # When I go to the connections page
    # And "+16175551212" sends SMS "no"
    # And I press the ignore button
    # And DJ cranks 5 times
    # And "+16175551212" should have received an SMS "OK, we'll ignore the request from Clay to be your fan."
    # And I should see "You've already ignored that person's request."

  Scenario: Follower attempts to follow twice in a row
    When "+14155551212" sends SMS "follow bob"
    And "+14155551212" sends SMS "follow bob"
    Then "+14155551212" should have received an SMS "OK, you'll be a fan of Bob, pending their acceptance."
    And "+14155551212" should have received an SMS "You've already asked to be a fan of Bob."

  Scenario: Follower attempts to follow after one follow already ignored
    When "+14155551212" sends SMS "follow bob"
    And "+16175551212" sends SMS "no"
    And "+14155551212" sends SMS "follow bob"
    And "+16175551212" sends SMS "yes"

    And DJ cranks 5 times
    Then "+14155551212" should have received an SMS "OK, you'll be a fan of Bob, pending their acceptance."
    And "+14155551212" should have received an SMS "Bob has approved your request to be a fan."

  Scenario: Fandom doesn't appear in activity feed until approved
    When "Alice" requests to follow "Bob/fooble" by SMS
    And I sign in via the login page with "Bob/fooble"
    Then I should not see "Alice is now a fan of Bob"

    When "+16175551212" sends SMS "yes"
    And I go to the activity page
    Then I should see "Alice is now a fan of Bob"

  @javascript
  Scenario: Fandom shows acceptance status on profile page
    Given the following accepted friendship exists:
      | user      | friend      |
      | name: Bob | name: Alice |
    When I sign in via the login page with "Alice/barley"
    And I fan "Bob"
    Then I should see "OK, you'll be a fan of Bob, pending their acceptance."

    When I go to the profile page for "Alice"
    Then I should see "Not following anyone yet"

    When "+16175551212" sends SMS "yes"
    And I go to the profile page for "Alice"
    Then I should see "Following Bob"

  @javascript
  Scenario: User can approve multiple follow requests by SMS
    When "Alice" requests to follow "Bob/fooble" by SMS
    And "Clay/bazquux" requests to follow "Bob/fooble" by web
    And "Don" requests to follow "Bob/fooble" by SMS

    When "+16175551212" sends SMS "yes"
    And I go to the activity page
    Then I should see "Alice is now a fan of Bob"

    When "+16175551212" sends SMS "yes 3"
    And I go to the activity page
    Then I should see "Don is now a fan of Bob"

    When "Ed" requests to follow "Bob/fooble" by SMS
    And "+16175551212" sends SMS "yes 3"
    And I go to the activity page
    Then I should see "Ed is now a fan of Bob"

    When "+16175551212" sends SMS "yes 2"
    And I go to the activity page
    Then I should see "Clay is now a fan of Bob"
