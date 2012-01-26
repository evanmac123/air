Feature: Admin sends activity dump

  Scenario: Admin sends activity dump
    Given the following demo exists:
      | name |
      | H Engage     |
    And time is frozen at "2011-05-01 15:00 EDT"
    And I sign in as an admin via the login page
    When I go to the admin "H Engage" demo page
    And I press "Send activity dump to Vlad"
    Then "vlad@hengage.com" should receive an email
    When "vlad@hengage.com" opens the email
    Then attachment 1 should be named "H_Engage-2011_05_01_1500.csv"
    And attachment 1 should be of type "text/csv"
