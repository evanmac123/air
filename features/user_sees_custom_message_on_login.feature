Feature: User sees, on login, a custom message set per demo

  Scenario: User sees custom message on login
    Given the following demo exists:
      | company name | login announcement    |
      | Awesome.com  | Eat Yr Fuckin Raisins |
    And the following user exists:
      | name | demo                      |
      | Joe  | company_name: Awesome.com |
    And "Joe" has password "foobar"

    When I sign in via the login page with "Joe/foobar"
    Then I should see "Eat Yr Fuckin Raisins"

    When I go to the activity page
    Then I should not see "Eat Yr Fuckin Raisins"
