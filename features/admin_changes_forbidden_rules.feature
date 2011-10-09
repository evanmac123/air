Feature: Admin changes forbidden rules

  Background:
    Given the following forbidden rule values exist:
      | value                     |
      | ate kitten                |
      | ate whole stick of butter |
      | drank six-pack            |
    And I sign in via the login page as an admin
    And I go to the forbidden rule admin page

  Scenario: Admin sees list of existing forbidden rules
    Then I should see "ate kitten"
    And I should see "ate whole stick of butter"
    And I should see "drank six-pack"

  Scenario: Admin adds another forbidden rule
    When I fill in "Value" with "smushed frog"
    And I press "Add forbidden rule"
    Then I should see "Forbidden rule smushed frog added"

  Scenario: Admin must specify value for new forbidden rule
    When I press "Add forbidden rule"
    Then I should see "Must specify a value for the forbidden rule"

  Scenario: Admin deletes forbidden rule
    When I press "Delete this forbidden rule"
    Then I should see "Forbidden rule ate kitten deleted"
    When I go to the forbidden rule admin page
    Then I should not see "ate kitten"
