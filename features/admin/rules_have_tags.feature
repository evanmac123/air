Feature: Admin rules have tags

  Background:
    Given the following user exists:
     | name  | is_site_admin |
     | jesus | true          |
    Given the following rule exists:
      | description | primary_tag     | demo                |
      | ridebike    | name: generated | name: FooCo |
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
    Then I should see "Tag was successfully created"
    And I should see "cheese"
    And I should see "curdled milk"

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

  Scenario: Admin can edit an existing tag
    When I go to the admin tags page
    And I follow "Edit"
    And I fill in "Name" with "george"
    And I fill in "Description" with "George Forman"
    And I click "Update Tag"
    Then I should not see "Name has already been taken"
    But I should see "george"
    And I should see "George Forman"
    And I should see "Tag updated"

  Scenario: Admin can delete an existing tag
    When I go to the admin tags page
    And I follow "Destroy"
    Then I should not see "black"
    And I should see "Tag deleted"
