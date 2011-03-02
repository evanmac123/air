Feature: Sign in
  In order to get access to protected sections of the site
  A user
  Should be able to sign in

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
      Then I should see "Signed in"
      And I should be signed in
      When I return next time
      Then I should be signed in

   Scenario: Signing in goes to the activity page
      Given I am signed up as "email@person.com/password"
      When I go to the sign in page
      And I sign in as "email@person.com/password"
      Then I should be on the activity page

   Scenario: Signing in is case insensitive
      Given I am signed up as "dude@example.com/foo"
      When I go to the sign in page
      And I sign in as "Dude@example.com/foo"
      Then I should see "Signed in"
