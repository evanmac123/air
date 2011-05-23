Feature: Full text search suggestions restrict their own length (to under 160 characters)

  Background:
    Given the following rules exist:
      | value                                                                 | demo                  |
      | a modest proposal                                                     | company_name: WordyCo |
      | an indecent proposal                                                  | company_name: WordyCo |
      | the creation of a lengthly proposal of an overlength rule             | company_name: WordyCo |
      | a brief suggestion                                                    | company_name: WordyCo |
      | a suggestion of incredible length that should not actually happen     | company_name: WordyCo |
      | the merest suggestion of a sliver of a thing happening                | company_name: WordyCo |
      | surely nobody would ever write a rule of length 65 characters or more | company_name: WordyCo |
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
