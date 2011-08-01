Feature: Admin sends blast SMS

  Background:
    Given the following users exist:
      | name | phone number | demo                |
      | Phil | +14155551212 | company_name: FooCo |
      | Vlad | +16175551212 | company_name: FooCo |
      | Dan  | +18085551212 | company_name: FooCo |
      | Sven | +13055551212 | company_name: BarCo |
    And I sign in as an admin via the login page
    And I go to the blast SMS page for "FooCo"

  Scenario: Admin sends immediate blast SMS
    And I fill in "Message body" with "Are we having fun yet?"
    And I press "Send blast"
    And DJ cranks 10 times
    Then "+14155551212" should have received SMS "Are we having fun yet?"
    And "+16175551212" should have received SMS "Are we having fun yet?"
    And "+18085551212" should have received SMS "Are we having fun yet?"
    And "+13055551212" should not have received any SMSes

  Scenario: Admin sends delayed blast SMS
    When time is frozen at "2010-05-01 12:59:59 EDT"
    And I go to the blast SMS page for "FooCo"
    And I fill in "Message body" with "Are we having fun yet?"
    And I set the datetime selector for "send at" to "2010 May 1 13:00"
    And I press "Send blast"
    And DJ cranks 10 times
    Then "+14155551212" should not have received any SMSes
    And "+16175551212" should not have received any SMSes
    And "+18085551212" should not have received any SMSes
    When time is frozen at "2010-05-01 13:00:00 EDT"
    And DJ cranks 10 times
    Then "+14155551212" should have received SMS "Are we having fun yet?"
    And "+16175551212" should have received SMS "Are we having fun yet?"
    And "+18085551212" should have received SMS "Are we having fun yet?"
    And "+13055551212" should not have received any SMSes

  Scenario: Restriction on blast SMS length
    Then I should see a restricted text field "Message body"
