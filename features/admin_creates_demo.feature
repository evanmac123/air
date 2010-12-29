Feature: Admin creates demo

  Scenario: Admin creates a demo for a sales meeting
    Given I am on the admin page
    Then I should see a list of demos
    And I should see "New Demo"
