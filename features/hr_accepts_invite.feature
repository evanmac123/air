Feature: HR accepts invite

  Scenario: HR person accepts invite from admin
    Given I am on the home page
    And I follow "HR accepts invite"
    Then I should be on the accept page
