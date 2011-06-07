Feature: When a user fans somebody, that's shown in the activity stream

Scenario: User makes a fan and that shows up in the stream
  Given the following users exist:
    | name | phone number | demo                  |
    | Dan  | +14155551212 | company_name: HEngage |
    | Vlad | +16175551212 | company_name: HEngage |
  And "Dan" has password "foo"
  When I sign in via the login page with "Dan/foo"
  And I go to the profile page for "Vlad"
  And I press "Be a fan"
  And I go to the activity page
  Then I should see "Dan is now a fan of Vlad"
