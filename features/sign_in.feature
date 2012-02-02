Feature: Sign in
  Scenario: User is not signed up
    Given no user exists with an email of "email@person.com"
    When I go to the sign in page
    And I sign in as "email@person.com/password"
    Then I should see "Bad email or password"
    And I should be signed out

  Scenario: User enters wrong password
    Given I am signed up as "email@person.com/password"
    When I go to the sign in page
    And I sign in as "email@person.com/wrongpassword"
    Then I should see "Bad email or password"
    And I should be signed out

  Scenario: User signs in successfully
    Given I am signed up as "email@person.com/password"
    When I go to the sign in page
    And I sign in as "email@person.com/password"
    Then I should not see "Signed in"
    But I should be signed in
    And I should be on the activity page
    When I return next time
    Then I should be signed in

  Scenario: Signing in goes to the activity page
    Given I am signed up as "email@person.com/password"
    When I go to the sign in page
    And I sign in as "email@person.com/password"
    Then I should be on the activity page

  Scenario: Signing in is case insensitive
    Given I am signed up as "dude@example.com/foobar"
    When I go to the sign in page
    And I sign in as "Dude@example.com/foobar"
    Then I should not see "Signed in"
    But I should be signed in
    And I should be on the activity page

  Scenario: User can sign in with SMS slug a.k.a. username, case-insensitively
    Given the following claimed user exists:
      | name      |
      | Bob Smith |
    And "Bob Smith" has password "foobar"
    When I go to the sign in page
    And I fill in the email field with "bobsmith"
    And I fill in the password field with "foobar"
    And I press "Let's play!"
    Then I should be on the activity page

    When I sign out
    And I go to the activity page
    Then I should be on the sign in page
    When I fill in the email field with "BoBSmith"
    And I fill in the password field with "foobar"
    And I press "Let's play!"
    Then I should be on the activity page
