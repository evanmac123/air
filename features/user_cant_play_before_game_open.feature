Feature: User can't play before game opens

  Scenario: User can't login before game opens
    Given the following demo exists:
      | name | begins at                 |
      | HoldYrHorses | 2011-05-01 00:00:00 -0400 |
    And the following user exists:
      | name | email           | demo                       |
      | Bob  | bob@example.com | name: HoldYrHorses |
    And "Bob" has the password "foobar"

    When time is frozen at "2011-04-30 23:59:59 -0400"
    And I sign in via the login page with "Bob/foobar"
    Then I should be on the activity page
    And I should see "Your game begins on May 01, 2011 at 12:00 AM Eastern"
    When I go to the profile page for "Bob"
    Then I should not see "Enter your new mobile number"
    And I should see "Your game begins on May 01, 2011 at 12:00 AM Eastern"

    When I go to the settings page for "Bob"
    Then I should not see "Your game begins on May 01, 2011 at 12:00 AM Eastern"
    But I should see "Notification Preferences"
    When I fill in "Change your username." with "somepig"
    And I press the button to save the user's settings
    Then I should be on the settings page
    And I should see "OK, your settings were updated."
    
    When time is frozen at "2011-05-01 00:01:00 -0400"
    And I sign in via the login page with "Bob/foobar"
    Then I should not see "Signed in"
    But I should be on the activity page
    And I should not see "Your game begins on May 01, 2011 at 12:00 AM Eastern"

  Scenario: Game without a set start time is open immediately      
    Given the following demo exists:
      | name |
      | AnyOldTime   |
    And the following user exists:
      | name | email           | demo                     |
      | Bob  | bob@example.com | name: AnyOldTime |
    And "Bob" has the password "foobar"

    When time is frozen at "1962-01-01 00:00:00"
    And I sign in via the login page with "Bob/foobar"
    Then I should not see "Your game begins on May 01, 2011 at 12:00 AM Eastern"

    When time is frozen at "1992-01-01 00:00:00"
    And I sign in via the login page with "Bob/foobar"
    Then I should not see "Your game begins on May 01, 2011 at 12:00 AM Eastern"

    When time is frozen at "2002-01-01 00:00:00"
    And I sign in via the login page with "Bob/foobar"
    Then I should not see "Your game begins on May 01, 2011 at 12:00 AM Eastern"

    When time is frozen at "2012-01-01 00:00:00"
    And I sign in via the login page with "Bob/foobar"
    Then I should not see "Your game begins on May 01, 2011 at 12:00 AM Eastern"

  Scenario: Admin can log in whenever they please
    Given the following demo exists:
      | name | begins at                 |
      | HoldYrHorses | 2011-05-01 00:00:00 -0400 |
    And the following user exists:
      | name | email            | is site admin | demo                       |
      | Bob  | bob@example.com  | false         | name: HoldYrHorses |
      | Adam | adam@example.com | true          | name: HoldYrHorses |
    And "Bob" has the password "foobar"
    And "Adam" has the password "barfing"

    When time is frozen at "2011-04-30 23:59:59 -0400"
    And I sign in via the login page with "Bob/foobar"
    Then I should be on the activity page
    And I should see "Your game begins on May 01, 2011 at 12:00 AM Eastern"

    When I sign in via the login page with "Adam/barfing"
    Then I should not see "Your game begins on May 01, 2011 at 12:00 AM Eastern"
