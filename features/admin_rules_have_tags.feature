Feature: Admin rules have tags

  Background:
    Given the following user exists:
      | name  | is_site_admin |
      | jesus | true     |
    Given the following rule exists:
      | description |
      | ridebike    |
    Given the following rule value exists:
      | value        | rule                  | is_primary |
      | rode a bike  | description: ridebike | true       |
    Given the following tags exist:
      | name     |
      | outdoors |
      | indoors  |
      | black    |
      | leather  |
    Given the following label exists:
      | tag            | rule                  |
      | name: outdoors | description: ridebike |
    Given "jesus" has password "bum"
    Given I sign in via the login page as "jesus/bum"
  Scenario: Admin can create new tags
    When I go to the new admin tag page
    Then I should see "Name"
  Scenario: Admin can associate a rule with a tag
    When I go to the rule edit page for "rode a bike"
    Then I should see "Primary"
    When I check the "leather" tag
    And I press "Update Rule"
    Then I should see "leather"
    And I should see "outdoors"
    Then show me the page
  Scenario: Admin can create a new rule with a tag
    When I go to the new admin rule page
    Then I should see "Primary"
    When I fill in "rule_primary_value" with "first primary"
    And I press "Create Rule"
    Then show me the page
    Then I should not see "undefined method"
