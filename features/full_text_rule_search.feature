Feature: Full text rule search

  Background:
    Given the following rules exist:
      | reply   | demo                  | suggestible |  
      | banana  | name: FooCorp | true        |  
      | Gross.  | name: FooCorp | true        |  
      | poison  | name: FooCorp | false       |  
      | workout | name: FooCorp | true        |  
      | cycled  | name: BarCorp | true        |  
      | risotto |                       | true        |  
      | happy   | name: FooCorp | true        |  
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
      | Dan  | +16175551212 | name: FooCorp |
    And "Dan" has the password "foobar"
    And I sign in via the login page with "Dan/foobar"
    And time is frozen at "2010-05-01 17:00:00"

  Scenario: User almost gets a command right
    When "+16175551212" sends SMS "ate baked alaska"
    Then "+16175551212" should have received an SMS 'I didn't quite get that. Text "a" for "ate banana", "b" for "ate kitten", or "s" to suggest we add what you sent.'
    
  Scenario: User can throw in punctuation all damn day and it won't break
    When "+16175551212" sends SMS "ate baked alaska!"
    And "+16175551212" sends SMS "worked out (at the gym)."
    And "+16175551212" sends SMS "ate banana's"
    And "+16175551212" sends SMS "worked out @ gym"
    Then "+16175551212" should have received an SMS 'I didn't quite get that. Text "a" for "ate banana", "b" for "ate kitten", or "s" to suggest we add what you sent.'
    Then "+16175551212" should have received an SMS 'I didn't quite get that. Text "a" for "worked out", or "s" to suggest we add what you sent.'

  Scenario: User picks a suggested command
    When "+16175551212" sends SMS "ate baked alaska"
    And "+16175551212" sends SMS "b"
    And I go to the activity page
    Then I should see "Dan ate kitten"
    Then "+16175551212" should have received an SMS 'I didn't quite get that. Text "a" for "ate banana", "b" for "ate kitten", or "s" to suggest we add what you sent.'
    And "+16175551212" should have received an SMS including "Gross."

  Scenario: Suggestions in the web page refer to typing, not texting
    When I enter the act code "ate baked alaska"
    Then I should see 'I didn't quite get that. Type "a" for "ate banana", "b" for "ate kitten", or "s" to suggest we add what you sent.'

  Scenario: User can pick suggested command via the website
    When I enter the act code "ate baked alaska"
    And I enter the special command "b"
    Then I should see the success message "Gross."

  Scenario: User can't pick a suggested command twice
    When "+16175551212" sends SMS "ate baked alaska"
    And "+16175551212" sends SMS "b"
    And "+16175551212" sends SMS "b"
    Then "+16175551212" should have received an SMS 'I didn't quite get that. Text "a" for "ate banana", "b" for "ate kitten", or "s" to suggest we add what you sent.'
    And "+16175551212" should have received an SMS including "Gross."
    And "+16175551212" should have received an SMS "Sorry, I don't understand what that means. Text "s" to suggest we add what you sent."    

  Scenario: User picks a suggested command index out of range
    When "+16175551212" sends SMS "ate baked alaska"
    And "+16175551212" sends SMS "c"
    Then "+16175551212" should have received an SMS 'I didn't quite get that. Text "a" for "ate banana", "b" for "ate kitten", or "s" to suggest we add what you sent.'
    And "+16175551212" should have received an SMS "Sorry, I don't understand what that means. Text "s" to suggest we add what you sent."    

  Scenario: User comes nowhere near a command
    When "+16175551212" sends SMS "fought eighteen bears"
    Then "+16175551212" should have received an SMS "Sorry, I don't understand what that means. Text "s" to suggest we add what you sent."    

  Scenario: User doesn't get a suggestion from a different demo
    When "+16175551212" sends SMS "rode unicycle"
    Then "+16175551212" should have received an SMS "Sorry, I don't understand what that means. Text "s" to suggest we add what you sent."    

  Scenario: User can get a suggestion from a standard playbook rule (belonging to no demo)
    When "+16175551212" sends SMS "made toast"
    Then "+16175551212" should have received an SMS including "made risotto"

  Scenario: Only primary rule values are suggested
    When "+16175551212" sends SMS "feeling like a million bucks"
    Then "+16175551212" should have received an SMS including "feel happy"
    And "+16175551212" should not have received an SMS including "feel great"
