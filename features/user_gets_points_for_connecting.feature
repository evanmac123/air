Feature: User gets points for connecting to another (if demo configured for it)

  Background:
    Given the following demo exists:
      | company name | points for connecting |
      | HMFEngage    | 5                     |
    And the following users exist:
      | name | phone number | demo                    |
      | Dan  | +14155551212 | company_name: HMFEngage |
      | Vlad | +16175551212 | company_name: HMFEngage |
    And "Dan" has password "foo"
    When I sign in via the login page as "Dan/foo"

  Scenario: User gets points for connecting
    When I go to the profile page for "Vlad"
    And I press "Follow"
    And I go to the activity page
    Then I should see "Dan is now a fan of Vlad"
    And I should see "+5 points"

  Scenario: User gets points for connecting just once
    When I go to the profile page for "Vlad"
    And I press "Follow"
    And I press "Unfollow"
    And I press "Follow"
    And I go to the activity page
    Then I should see "+5 points" just once
