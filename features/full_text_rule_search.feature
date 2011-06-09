Feature: Full text rule search

  Background:
    Given the following rules exist:
      | reply   | demo                  | suggestible |  
      | banana  | company_name: FooCorp | true        |  
      | Gross.  | company_name: FooCorp | true        |  
      | poison  | company_name: FooCorp | false       |  
      | workout | company_name: FooCorp | true        |  
      | cycled  | company_name: BarCorp | true        |  
      | risotto |                       | true        |  
      | happy   | company_name: FooCorp | true        |  
    And the following rule values exist: 
      | value        | is_primary | rule           |
      | ate banana   | true       | reply: banana  |
      | ate kitten   | true       | reply: Gross.  |
      | ate poison   | true       | reply: poison  |
      | worked out   | true       | reply: workout |
      | rode bicycle | true       | reply: cycled  |
      | made risotto | true       | reply: risotto |
      | feel happy   | true       | reply: happy   |
      | feel great   | false      | reply: happy   |
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

  Scenario: User can throw in punctuation all damn day and it won't break
    When "+16175551212" sends SMS "ate baked alaska!"
    And "+16175551212" sends SMS "worked out (at the gym)."
    And "+16175551212" sends SMS "ate banana's"
    And "+16175551212" sends SMS "worked out @ gym"
    Then "+16175551212" should have received an SMS 'I didn't quite get what you meant. Maybe try (1) "ate banana" or (2) "ate kitten"? Or text S to suggest we add what you sent.'
    Then "+16175551212" should have received an SMS 'I didn't quite get what you meant. Maybe try (1) "worked out"? Or text S to suggest we add what you sent.'

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

  Scenario: Only primary rule values are suggested
    When "+16175551212" sends SMS "feeling like a million bucks"
    Then "+16175551212" should have received an SMS including "feel happy"
    And "+16175551212" should not have received an SMS including "feel great"
