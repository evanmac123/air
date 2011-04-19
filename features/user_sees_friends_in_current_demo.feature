Feature: User sees only friends in current demo

  Background:
    Given the following users exist:
      | name | demo                     |
      | Dan  | company_name: Thoughtbot |
      | Chad | company_name: Thoughtbot |
      | Nick | company_name: Thoughtbot |
      | Vlad | company_name: H Engage   |
      | Phil | company_name: H Engage   |

    And "Dan" follows "Chad"
    And "Dan" follows "Vlad"
    And "Dan" follows "Phil"
    And "Nick" follows "Dan"
    And "Vlad" follows "Dan"
    And "Phil" follows "Dan"

  Scenario: User sees only friends in current demo, with correct counts
    When I sign in via the login page
    And I go to the profile page for "Dan"
    Then I should see "1 followers"
    And I should see "1 following"

  Scenario: User sees correct follower and following count after moving demos
    When an admin moves "Dan" to the demo "H Engage"
    And I sign in via the login page
    And I go to the profile page for "Dan"
    Then I should see "2 followers"
    And I should see "2 following"
