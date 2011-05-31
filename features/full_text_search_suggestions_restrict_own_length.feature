Feature: Full text search suggestions restrict their own length (to under 160 characters)

  Background:
    Given the following rules exist:
      | reply      | demo                  | 
      | modest     | company_name: WordyCo | 
      | indecent   | company_name: WordyCo | 
      | lengthly   | company_name: WordyCo | 
      | brief      | company_name: WordyCo | 
      | incredible | company_name: WordyCo | 
      | merest     | company_name: WordyCo | 
      | surely     | company_name: WordyCo | 
    And the following rule values exist:
      | value                                                                 | is_primary | rule              |
      | a modest proposal                                                     | true       | reply: modest     |
      | an indecent proposal                                                  | true       | reply: indecent   |
      | the creation of a lengthly proposal of an overlength rule             | true       | reply: lengthly   |
      | a brief suggestion                                                    | true       | reply: brief      |
      | a suggestion of incredible length that should not actually happen     | true       | reply: incredible |
      | the merest suggestion of a sliver of a thing happening                | true       | reply: merest     |
      | surely nobody would ever write a rule of length 65 characters or more | true       | reply: surely     |
    And the following user exists:
      | phone number | demo                  |
      | +14155551212 | company_name: WordyCo |

  Scenario: A suggestion that can be brought under length by dropping one suggestion
    When "+14155551212" sends SMS "proposal"
    Then "+14155551212" should have received an SMS 'I didn't quite get what you meant. Maybe try (1) "a modest proposal" or (2) "an indecent proposal"? Or text S to suggest we add what you sent.'

  Scenario: A suggestion that can be brought under length by dropping two suggestions
    When "+14155551212" sends SMS "suggestion"
    Then "+14155551212" should have received an SMS 'I didn't quite get what you meant. Maybe try (1) "a brief suggestion"? Or text S to suggest we add what you sent.'

  Scenario: A suggestion with ridiculously long rules where no suggestion will fit
    When "+14155551212" sends SMS "nobody would ever"
    Then "+14155551212" should have received an SMS "Sorry, I don't understand what that means. Text S to suggest we add what you sent."    
