Feature: User approves or ignores follower

  Background:
    Given the following demo exists:
      | company name |
      | FooCo        |
    And the following users exist:
      | name  | email             | phone number | demo                |
      | Alice | alice@example.com | +14155551212 | company_name: FooCo |
      | Bob   | bob@example.com   | +16175551212 | company_name: FooCo |
    And "Bob" has password "foo"
    And "Alice" has password "bar"

  Scenario: Follower follows by SMS, followed accepts via SMS
    When "Alice" requests to follow "Bob/foo" by SMS
    Then "Bob/foo" should be able to accept "Alice" by SMS

  Scenario: Follower follows by SMS, followed ignores via SMS
    When "Alice" requests to follow "Bob/foo" by SMS
    Then "Bob/foo" should be able to ignore "Alice" by SMS

  Scenario: Follower follows by SMS, followed accepts via web
    When "Alice" requests to follow "Bob/foo" by SMS
    Then "Bob/foo" should be able to accept "Alice" by web

  Scenario: Follower follows by SMS, followed ignores via web
    When "Alice" requests to follow "Bob/foo" by SMS
    Then "Bob/foo" should be able to ignore "Alice" by web

  Scenario: Follower follows by web, followed accepts via SMS
    When "Alice/bar" requests to follow "Bob/foo" by web
    Then "Bob/foo" should be able to accept "Alice" by SMS

  Scenario: Follower follows by web, followed ignores via SMS
    When "Alice/bar" requests to follow "Bob/foo" by web
    Then "Bob/foo" should be able to ignore "Alice" by SMS

  Scenario: Follower follows by web, followed accepts via web
    When "Alice/bar" requests to follow "Bob/foo" by web
    Then "Bob/foo" should be able to accept "Alice" by web

  Scenario: Follower follows by web, followed ignores via web
    When "Alice/bar" requests to follow "Bob/foo" by web
    Then "Bob/foo" should be able to ignore "Alice" by web

  Scenario: Followed attempts to accept someone who did not request to follow
    When "+14155551212" sends SMS "accept blehbleh"
    Then "+14155551212" should have received an SMS "Sorry, nobody with the unique ID blehbleh has requested to be your fan."

  Scenario: Follower attempts to follow twice in a row
    When "+14155551212" sends SMS "follow bbob"
    And "+14155551212" sends SMS "follow bbob"
    Then "+14155551212" should have received an SMS "OK, you'll be a fan of Bob, pending their acceptance."
    And "+14155551212" should have received an SMS "You've already asked to be a fan of Bob."

  Scenario: Follower attempts to follow after one follow already ignored
    When "+14155551212" sends SMS "follow bbob"
    And "+16175551212" sends SMS "ignore aalice"
    And "+14155551212" sends SMS "follow bbob"
    And "+16175551212" sends SMS "accept aalice"

    And DJ cranks 5 times
    Then "+14155551212" should have received an SMS "OK, you'll be a fan of Bob, pending their acceptance."
    And "+14155551212" should have received an SMS "Bob has approved your request to be a fan."

  Scenario: User can choose notification by email
    When I sign in via the login page with "Bob/foo"
    And I go to the profile page for "Bob"
    And I select "Send an email" from "When somebody requests to be my fan:"
    And I press the button to save notification settings
    And "+14155551212" sends SMS "follow bbob"
    And DJ cranks 5 times

    Then "bob@example.com" should have received a follow notification email about "Alice"
    But "+16175551212" should not have received any SMSes

  Scenario: User can choose notification by SMS
    When I sign in via the login page with "Bob/foo"
    And I go to the profile page for "Bob"
    And I select "Send an SMS" from "When somebody requests to be my fan:"
    And I press the button to save notification settings
    And "+14155551212" sends SMS "follow bbob"
    And DJ cranks 5 times

    Then "+16175551212" should have received SMS "Alice has asked to be your fan. Text ACCEPT AALICE to accept, IGNORE AALICE to ignore (in which case they won't be notified)"
    And "bob@example.com" should have no emails

  Scenario: User can choose notification by email and SMS
    When I sign in via the login page with "Bob/foo"
    And I go to the profile page for "Bob"
    And I select "Send both an SMS and an email" from "When somebody requests to be my fan:"
    And I press the button to save notification settings
    And "+14155551212" sends SMS "follow bbob"
    And DJ cranks 5 times

    Then "+16175551212" should have received SMS "Alice has asked to be your fan. Text ACCEPT AALICE to accept, IGNORE AALICE to ignore (in which case they won't be notified)"
    And "bob@example.com" should have received a follow notification email about "Alice"

  Scenario: User can choose notification by neither email nor SMS
    When I sign in via the login page with "Bob/foo"
    And I go to the profile page for "Bob"
    And I select "Send neither an SMS nor an email" from "When somebody requests to be my fan:"
    And I press the button to save notification settings
    And "+14155551212" sends SMS "follow bbob"
    And DJ cranks 5 times

    Then "+16175551212" should not have received any SMSes
    And "bob@example.com" should have no emails

  Scenario: Fandom doesn't appear in activity feed until approved
    When "Alice" requests to follow "Bob/foo" by SMS
    And I sign in via the login page with "Bob/foo"
    Then I should not see "Alice is now a fan of Bob"

    When "+16175551212" sends SMS "accept aalice"
    And I go to the activity page
    Then I should see "Alice is now a fan of Bob"

  Scenario: Fandom not reflected on connections page until approved
    Given the following accepted friendship exists:
      | user      | friend      |
      | name: Bob | name: Alice |
    When I sign in via the login page with "Alice/bar"
    And I go to the connections page
    And I fan "Bob"
    Then I should see "OK, you'll be a fan of Bob, pending their acceptance."
    And I should not see "Bob" as a person I'm following

    When "+16175551212" sends SMS "accept aalice"
    Then I should see "Bob" as a person I'm following
