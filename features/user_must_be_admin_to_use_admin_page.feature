Feature: User must be a site admin to use an admin page

  Scenario: Admin tries to go to admin page
    Given I sign in via the login page as an admin
    When I go to the admin page
    Then I should be on the admin page

  Scenario: Regular user tries to go to admin page, and is rebuffed
    Given I sign in via the login page
    When I go to the admin page
    Then I should be on the activity page

  Scenario: Admin has handy link to go to admin page
    Given I sign in via the login page as an admin
    When I follow "Admin"
    Then I should be on the admin page

  Scenario: Regular user sees no link to the admin page
    Given I sign in via the login page
    When I go to the admin page
    Then I should not see "Admin"
