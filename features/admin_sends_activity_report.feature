Feature: Admin sends activity report

  Scenario: Admin sends an activity report
    Given the following demo exists:
      | name     |
      | H Engage |
    And time is frozen at "2011-05-01 15:00"
    And I sign in as an admin via the login page
    When I go to the admin "H Engage" demo page
    And I press "Send me an Activity Report"
    Then I should see "An Activity Report has been sent"
    And "darth_1@sunni.ru" should receive an email
    When "darth_1@sunni.ru" opens the email
    Then attachment 1 should be named "H_Engage_2011_05_01_1500.csv"
    And attachment 1 should be of type "text/csv"

