Feature: Admin sends invite

  Scenario: Admin invites participants of sales meeting
    Given I am on the admin page
    When I follow "3M"
    Then I should be on the invite page
