Feature: Admin rules have tags

  Background:
    Given the following user exists:
      | name  | is_site_admin |
      | jesus | true     |
    Given the following rule exists:
      | description |
      | ridebike    |
    Given the following rule value exists:
      | value        | rule                  |
      | rode a bike  | description: ridebike |
    Given the following tag exists:
      | name     |
      | outdoors |
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
