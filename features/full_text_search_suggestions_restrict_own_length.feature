Feature: Full text search suggestions restrict their own length (to under 160 characters)

  Background:
    Given the following rules exist:
      | reply      | demo                  | 
      | modest     | name: WordyCo | 
      | indecent   | name: WordyCo | 
      | lengthly   | name: WordyCo | 
      | brief      | name: WordyCo | 
      | incredible | name: WordyCo | 
      | merest     | name: WordyCo | 
      | surely     | name: WordyCo | 
    And the following rule values exist:
      | value                                                                                                       | is_primary | rule              |
      | a modest proposal                                                                                           | true       | reply: modest     |
      | an indecent proposal                                                                                        | true       | reply: indecent   |
      | the creation of a lengthly proposal of an overlength rule                                                   | true       | reply: lengthly   |
      | a brief suggestion                                                                                          | true       | reply: brief      |
      | a suggestion of incredible length that should not actually happen                                           | true       | reply: incredible |
      | the merest suggestion of a sliver of a thing happening                                                      | true       | reply: merest     |
      | surely nobody would ever write a rule of length 65 characters or more, I mean, that would be just psychotic | true       | reply: surely     |
    And the following claimed user exists:
      | phone number | demo          |
      | +14155551212 | name: WordyCo |

  Scenario: A suggestion that can be brought under length by dropping one suggestion
    When "+14155551212" sends SMS "proposal"
    Then "+14155551212" should have received an SMS 'I didn't quite get what "proposal" means. Text "a" for "a modest proposal", "b" for "an indecent proposal", or "s" to suggest we add it.'

  Scenario: A suggestion that can be brought under length by dropping two suggestions
    When "+14155551212" sends SMS "suggestion"
    Then "+14155551212" should have received an SMS 'I didn't quite get what "suggestion" means. Text "a" for "a brief suggestion", or "s" to suggest we add it.'

  Scenario: A suggestion with ridiculously long rules where no suggestion will fit
    When "+14155551212" sends SMS "nobody would ever"
    Then "+14155551212" should have received an SMS "Sorry, I don't understand what "nobody would ever" means. Text "s" to suggest we add it."    
