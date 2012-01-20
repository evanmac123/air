Feature: Admin rules have tags

  Background:
    Given the following user exists:
      | name  | is_site_admin |
     | jesus | true          |
    Given the following rule exists:
      | description | primary_tag     | demo                |
      | ridebike    | name: generated | company_name: FooCo |
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
    Given "jesus" has password "bumble"
    Given I sign in via the login page as "jesus/bumble"
  Scenario: Admin can create new tags
    When I go to the new admin tag page
    And I fill in "Name" with "cheese"
    And I fill in "Description" with "curdled milk"
    And I press "Create Tag"
    Then I should see "Name: cheese Description: curdled milk"

  Scenario: Admin can edit a rule to associate it with a tag
    When I go to the rule edit page for "rode a bike"
    Then I should see "Primary"
    Then the "outdoors" checkbox should be checked
    When I check the "leather" tag
    And I press "Update Rule"
    Then I should see "leather"
    And I should see "outdoors"
  Scenario: Admin can create a new rule and associate it with a tag
    When I go to the new admin rule page
    Then I should see "Primary"
    When I fill in "Primary value" with "first primary"
    And I check the "leather" tag
    And I press "Create Rule"
    Then I should see "first primary"
    And I should see "leather"

  Scenario: Admin can view the rules/index page
    When I go to the admin rules page for "FooCo"
    Then I should see "generated"

  Scenario: When editing a rule, primary tag radio button shows up checked
    When I go to the rule edit page for "rode a bike"
    Then the radio button for "generated" should be checked
