Feature: Demos are kept separate
  Background:
    Given the following user with phones exist:
      | email           | name | demo             |
      | dan@example.com | Dan  | company name: 3M |
      | bob@example.com | Bob  | company name: 3M |
      | ned@example.com | Ned  | company name: Xe |

  Scenario: User accepting invitation sees other users in the same demo    
    Given "dan@example.com" has received an invitation
    And I go to the invitation page for "dan@example.com"
    When I accept the invitation
    Then I should be on the activity page
    And I should see a link to the profile page for "Bob"
    And I should not see a link to the profile page for "Ned"

  Scenario: User logging in sees other users in the same demo
    Given "Dan" has the password "foobar"
    When I sign in via the login page as "Dan/foobar"
    Then I should be on the activity page
    And I should see a link to the profile page for "Bob"
    And I should not see a link to the profile page for "Ned"
