Feature: Admin creates demo

  Scenario: Admin creates a demo for a sales meeting
    Given I am on the admin page
    When I follow "New Demo"
    And I fill in "Company name" with "3M"
    And I press "Submit"
    Then I should be on the admin "3M" demo page
