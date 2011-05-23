Feature: Full text rule search

  Background:
    Given the following rules exist:
      | value        | suggestible | reply  | demo                  |
      | ate banana   | true        |        | company_name: FooCorp |
      | ate kitten   | true        | Gross. | company_name: FooCorp |
      | ate poison   | false       |        | company_name: FooCorp |
      | worked out   | true        |        | company_name: FooCorp |
      | rode bicycle | true        |        | company_name: BarCorp |
      | made risotto | true        |        |                       |
    And the following user exists:
      | name | phone number | demo                  |
      | Dan  | +16175551212 | company_name: FooCorp |
    And "Dan" has the password "foo"
    And I sign in via the login page with "Dan/foo"
    And time is frozen at "2010-05-01 17:00:00"

  Scenario: User almost gets a command right
    When "+16175551212" sends SMS "ate baked alaska"
    And I go to the bad message log page
    Then "+16175551212" should have received an SMS 'I didn't quite get what you meant. Maybe try (1) "ate banana" or (2) "ate kitten"? Or text S to suggest we add what you sent.'
    And I should see the following new bad SMS messages:
      | name | phone_number | message_body     | received_at         |
      | Dan  | +16175551212 | ate baked alaska | 2010-05-01 17:00:00 |
    And I should see "(has automated suggestion)"
    And I should see `System automatically replied: I didn't quite get what you meant. Maybe try (1) "ate banana" or (2) "ate kitten"? Or text S to suggest we add what you sent.`

  Scenario: User picks a suggested command
    When "+16175551212" sends SMS "ate baked alaska"
    And "+16175551212" sends SMS "meant 2"
    And I go to the activity page
    Then I should see "Dan ate kitten"
    And "+16175551212" should have received an SMS 'I didn't quite get what you meant. Maybe try (1) "ate banana" or (2) "ate kitten"? Or text S to suggest we add what you sent.'
    And "+16175551212" should have received an SMS including "Gross."

  Scenario: User can pick suggested command via the website
    When I enter the act code "ate baked alaska"
    And I enter the special command "meant 2"
    Then I should see the success message "Gross."

  Scenario: User can't pick a suggested command twice
    When "+16175551212" sends SMS "ate baked alaska"
    And "+16175551212" sends SMS "meant 2"
    And "+16175551212" sends SMS "meant 2"
    And "+16175551212" should have received an SMS 'I didn't quite get what you meant. Maybe try (1) "ate banana" or (2) "ate kitten"? Or text S to suggest we add what you sent.'
    And "+16175551212" should have received an SMS including "Gross."
    And "+16175551212" should have received an SMS "Sorry, I don't understand what that means. Text S to suggest we add what you sent."    

  Scenario: User picks a suggested command index out of range
    When "+16175551212" sends SMS "ate baked alaska"
    And "+16175551212" sends SMS "meant 3"
    Then "+16175551212" should have received an SMS 'I didn't quite get what you meant. Maybe try (1) "ate banana" or (2) "ate kitten"? Or text S to suggest we add what you sent.'
    And "+16175551212" should have received an SMS "Sorry, I don't understand what that means. Text S to suggest we add what you sent."    

  Scenario: User comes nowhere near a command
    When "+16175551212" sends SMS "fought eighteen bears"
    And I go to the bad message log page
    Then "+16175551212" should have received an SMS "Sorry, I don't understand what that means. Text S to suggest we add what you sent."    
    And I should see the following new bad SMS messages:
      | name | phone_number | message_body          | received_at         |
      | Dan  | +16175551212 | fought eighteen bears | 2010-05-01 17:00:00 |
    And I should not see "(has automated suggestion)"
    And I should not see "Sorry, I don't understand what that means."

  Scenario: User doesn't get a suggestion from a different demo
    When "+16175551212" sends SMS "rode unicycle"
    Then "+16175551212" should have received an SMS "Sorry, I don't understand what that means. Text S to suggest we add what you sent."    

  Scenario: User can get a suggestion from a standard playbook rule (belonging to no demo)
    When "+16175551212" sends SMS "made toast"
    Then "+16175551212" should have received an SMS including "made risotto"
