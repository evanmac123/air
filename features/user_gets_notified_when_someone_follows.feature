Feature: User gets notified when someone follows them
  Background:
    Given the following users exist:
      | name | phone_number | demo                  |
      | Dan  | +14155551212 | company_name: HEngage |
      | Vlad | +16178675309 | company_name: HEngage |
    And "Vlad" has the password "foo"

  Scenario: User gets an SMS when another user follows them
    When I sign in via the login page as "Vlad/foo"
    And I go to the user directory page
    And I fan "Dan"
    And DJ cranks once
    Then "+14155551212" should have received an SMS "Vlad is now your fan on HEngage."

  Scenario: User can switch off follow notifications
    Given "Dan" has the password "foo"
    When I sign in via the login page as "Dan/foo"
    And I go to the profile page for "Dan"
    And I uncheck "Send me an SMS when somebody follows me"
    And I press the button to update follow notification status
    And I sign out
    And I sign in via the login page as "Vlad/foo"
    And I go to the user directory page
    And I fan "Dan"
    Then "+14155551212" should not have received an SMS "Vlad is now your fan on HEngage."
