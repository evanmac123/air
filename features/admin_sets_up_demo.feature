Feature: Admin sets up demo

  Scenario: Admin sets up demo
    Given I am on the admin page
    When I follow "New Demo"
    And I fill in "Company name" with "3M"
    And I fill in "Victory threshold" with "100"
    And I press "Submit"
    Then I should be on the admin "3M" demo page
    When I follow "Admin"
    Then I should be on the admin page
    Then I should see "3M (100 points to win)"

  # something's wrong with this step
  # need to ask thoughtbot team
  # @akephalos
  # Scenario: Admin adds user
  #   Given a demo exists with a company name of "3M"
  #   And I am on the admin "3M" demo page
  #   When I follow "Add new user"
  #   And I fill in "Name" with "Bobby Jones"
  #   And I fill in "Email" with "bobby@example.com"
  #   And I press "Submit"
  #   Then I should be on the admin "3M" demo page
  #   And I should see "Bobby Jones"
