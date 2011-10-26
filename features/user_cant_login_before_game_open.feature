Feature: User can't login before game opens

  Scenario: User can't login before game opens
    Given the following demo exists:
      | company name | begins at                 |
      | HoldYrHorses | 2011-05-01 00:00:00 -0400 |
    And the following user exists:
      | name | email           | demo                       |
      | Bob  | bob@example.com | company_name: HoldYrHorses |
    And "Bob" has the password "foo"

    When time is frozen at "2011-04-30 23:59:59 -0400"
    And I sign in via the login page with "Bob/foo"
    Then I should not see "Signed in"
    And I should see "Your game begins on May 01, 2011 at 12:00 AM Eastern"
    When I go to the profile page for "Bob"
    Then I should not see "Enter your new mobile number"
    And I should see "Your game begins on May 01, 2011 at 12:00 AM Eastern"
    
    When time is frozen at "2011-05-01 00:01:00 -0400"
    And I sign in via the login page with "Bob/foo"
    Then I should see "Signed in"

  Scenario: Game without a set start time is open immediately      
    Given the following demo exists:
      | company name |
      | AnyOldTime   |
    And the following user exists:
      | name | email           | demo                     |
      | Bob  | bob@example.com | company_name: AnyOldTime |
    And "Bob" has the password "foo"

    When time is frozen at "1962-01-01 00:00:00"
    And I sign in via the login page with "Bob/foo"
    Then I should see "Signed in"

    When time is frozen at "1992-01-01 00:00:00"
    And I sign in via the login page with "Bob/foo"
    Then I should see "Signed in"

    When time is frozen at "2002-01-01 00:00:00"
    And I sign in via the login page with "Bob/foo"
    Then I should see "Signed in"

    When time is frozen at "2012-01-01 00:00:00"
    And I sign in via the login page with "Bob/foo"
    Then I should see "Signed in"

  Scenario: Admin can log in whenever they please
    Given the following demo exists:
      | company name | begins at                 |
      | HoldYrHorses | 2011-05-01 00:00:00 -0400 |
    And the following user exists:
      | name | email            | is site admin | demo                       |
      | Bob  | bob@example.com  | false         | company_name: HoldYrHorses |
      | Adam | adam@example.com | true          | company_name: HoldYrHorses |
    And "Bob" has the password "foo"
    And "Adam" has the password "bar"

    When time is frozen at "2011-04-30 23:59:59 -0400"
    And I sign in via the login page with "Bob/foo"
    Then I should not see "Signed in"
    And I should see "Your game begins on May 01, 2011 at 12:00 AM Eastern"

    When I sign in via the login page with "Adam/bar"
    Then I should see "Signed in"
    And I should not see "Your game begins on May 01, 2011 at 12:00 AM Eastern"
