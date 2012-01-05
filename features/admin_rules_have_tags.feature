Feature: Admin rules have tags

  Background:
    Given the following rule exists:
      | description |
      | ridebike    |
    Given the following tag exists:
      | name     |
      | outdoors |
    Given the following label exists:
      | tag            | rule                  |
      | name: outdoors | description: ridebike |

  Scenario: Admin can create new tags
    When I go to the admin new tag page
    Then I should see "Name"
