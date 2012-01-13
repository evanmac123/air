Feature: Admin sees users who have a mobile number on their account

  Scenario: Admin sees users who have a mobile number on their account
    Given the following users exist:
      | name       | phone_number | demo                          |
      | John Smith | +14155551212 | company_name: DaimlerChrysler |
      | Paul Jones | +16179876543 | company_name: DaimlerChrysler |
      | Fred Smith | +19086969696 | company_name: Dreamworks      |
      | Bob Foobar |              | company_name: DaimlerChrysler |
      | 23D00d     | +17075551212 | company_name: DaimlerChrysler |
      | $am        | +19995551212 | company_name: DaimlerChrysler |
    And I sign in as an admin via the login page
    And I go to the admin "DaimlerChrysler" demo page 
    Then I should see "4 users have added mobile numbers to their accounts"

    When I follow "F"
    Then I should not see "+19086969696"
    And I should not see "+14155551212"
    And I should not see "+16179876543"
    And I should not see "+17075551212"
    And I should not see "+19995551212"

    When I follow "J"
    Then I should see "+14155551212"
    And I should not see "+16179876543"
    And I should not see "+19086969696"
    And I should not see "+17075551212"
    And I should not see "+19995551212"

    When I follow "P"
    Then I should see "+16179876543"
    And I should not see "+14155551212"
    And I should not see "+19086969696"
    And I should not see "+17075551212"
    And I should not see "+19995551212"

    When I follow "non-alpha"
    Then I should see "+17075551212"
    And I should see "+19995551212"
    And I should not see "+14155551212"
    And I should not see "+16179876543"
    And I should not see "+19086969696"
