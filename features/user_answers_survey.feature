Feature: Surveys with prompts that go out at certain times

Background:
  Given the following claimed users exist:
    | name | phone number | demo                |
    | Dan  | +14155551212 | company_name: FooCo |
    | Vlad | +16175551212 | company_name: FooCo |
    | Tom  | +18085551212 | company_name: FooCo |
    | Bob  | +14105551212 | company_name: FooCo |
    | Sam  | +19995551212 | company_name: BarCo |
  And the following survey exists:
    | name                | open_at              | close_at             | demo                |
    | FooCo Health Survey | 2011-05-01 11:00 UTC | 2011-05-01 21:00 UTC | company_name: FooCo |
  And the following survey questions exist:
    | text                                     | index | points | survey                    |
    | Do you smoke crack?                      |     1 |        | name: FooCo Health Survey |
    | Do you like cheese?                      |     2 |      5 | name: FooCo Health Survey |
    | How important is doing what you're told? |     3 |        | name: FooCo Health Survey |
  And the following survey valid answers exist:
    | value | survey_question |
    | 1     | index: 1        |
    | 2     | index: 1        |
    | 1     | index: 2        |
    | 2     | index: 2        |
    | 1     | index: 3        |
    | 2     | index: 3        |
    | 3     | index: 3        |
    | 4     | index: 3        |
    | 5     | index: 3        |
  And the following survey prompts exist:
    | send_time            | text                                                           | survey                    |
    | 2011-05-01 13:00 UTC | Answer this, peon:                                             | name: FooCo Health Survey |
    | 2011-05-01 15:00 UTC | Answer the remaining %remaining_questions:                     | name: FooCo Health Survey |
    | 2011-05-01 17:00 UTC | Answer the remaining %remaining_questions or else:             | name: FooCo Health Survey |
    | 2011-05-01 19:00 UTC | This is your last chance to answer these %remaining_questions: | name: FooCo Health Survey |
    And "Dan" has the password "foobar"
   
  Scenario: Survey sends first prompt to everyone in the demo
    Given time is frozen at "2011-05-01 13:00 UTC"
    When DJ cranks once
    And DJ cranks 10 times
    Then "+14155551212" should have received an SMS "Answer this, peon: Do you smoke crack?"
    And "+16175551212" should have received an SMS "Answer this, peon: Do you smoke crack?"
    And "+18085551212" should have received an SMS "Answer this, peon: Do you smoke crack?"
    And "+14105551212" should have received an SMS "Answer this, peon: Do you smoke crack?"
    And "+19995551212" should not have received any SMSes

  Scenario: Prompt not sent prematurely
    Given time is frozen at "2011-05-01 12:59 UTC"
    When DJ cranks once
    And DJ cranks 10 times
    Then "+14155551212" should not have received any SMSes
    And "+16175551212" should not have received any SMSes
    And "+18085551212" should not have received any SMSes
    And "+14105551212" should not have received any SMSes
    And "+19995551212" should not have received any SMSes

  Scenario: User can kick off survey by asking for it if survey is open
    Given time is frozen at "2011-05-01 12:59:59 UTC"
    When DJ cranks once
    And DJ cranks 10 times
    Then "+14155551212" should not have received any SMSes

    When "+14155551212" sends SMS "survey"
    Then "+14155551212" should have received an SMS "Do you smoke crack?"

    When "+14155551212" sends SMS "1"
    And I dump all sent texts
    Then "+14155551212" should have received an SMS "Do you like cheese?"

  Scenario: User can't kick off survey by asking for it if survey is not currently open
    Given time is frozen at "2011-05-01 10:59:59 UTC"
    And "+14155551212" sends SMS "survey"
    Then "+14155551212" should have received an SMS "Sorry, there is not currently a survey open."

    Given time is frozen at "2011-05-01 21:00:01 UTC"
    And "+14155551212" sends SMS "survey"
    Then "+14155551212" should have received an SMS "Sorry, there is not currently a survey open."

  Scenario: Survey sends second prompt to everyone in the demo who hasn't answered every question
    Given time is frozen at "2011-05-01 15:00 UTC"
    And the following survey answers exist:
      | user       | survey question |
      | name: Dan  | index: 1        |
      | name: Dan  | index: 2        |
      | name: Dan  | index: 3        |
      | name: Vlad | index: 1        |
      | name: Vlad | index: 2        |
      | name: Tom  | index: 1        |
    When DJ cranks once
    And DJ cranks 20 times
    Then "+16175551212" should have received an SMS "Answer the remaining question: How important is doing what you're told?"
    And "+18085551212" should have received an SMS "Answer the remaining 2 questions: Do you like cheese?"
    And "+14105551212" should have received an SMS "Answer the remaining 3 questions: Do you smoke crack?"
    And "+14155551212" should not have received any SMSes
    And "+19995551212" should not have received any SMSes

  Scenario: No questions from old surveys show up
    Given the following survey exists:
      | name                | open_at              | close_at             | demo                |
      | New Health Survey   | 2011-06-01 13:00 UTC | 2011-06-01 21:00 UTC | company_name: FooCo |
    And the following survey questions exist:
      | text                                    | index | points | survey                  |
      | Where are the snowfalls of yesteryear?  |     1 |        | name: New Health Survey |
      | What's the matter with kids these days? |     2 |        | name: New Health Survey |
      | Whither Canada?                         |     3 |        | name: New Health Survey |
    And the following survey valid answers exist:
      | value | survey_question                              |
      | 1     | text: Where are the snowfalls of yesteryear? |
    And time is frozen at "2011-06-01 15:00 UTC"
    And "+14155551212" sends SMS "1"
    Then "+14155551212" should not have received an SMS including "How much do you like stuff?"

  Scenario: Answers from old surveys shouldn't count against current surveys
    Given the following survey exists:
      | name                | open_at              | close_at             | demo                |
      | Old Health Survey   | 2010-05-01 13:00 UTC | 2010-05-01 21:00 UTC | company_name: FooCo |
    And the following survey questions exist:
      | text                                    | index | points | survey                  |
      | Where are the snowfalls of yesteryear?  |     1 |        | name: Old Health Survey |
      | What's the matter with kids these days? |     2 |        | name: Old Health Survey |
      | Whither Canada?                         |     3 |        | name: Old Health Survey |
    And the following survey answers exist:
      | user       | survey question                              |
      | name: Dan  | text: Where are the snowfalls of yesteryear? |
    And time is frozen at "2011-05-01 15:00 UTC"
    When "+14155551212" sends SMS "1"
    Then "+14155551212" should not have received an SMS including "How important is doing what you're told?"

  Scenario: User responds to question during the window with a good value
    Given time is frozen at "2011-05-01 15:00 UTC"
    When "+14155551212" sends SMS "1"
    And I sign in via the login page with "Dan/foobar"
    And I go to the activity page
    Then "+14155551212" should have received an SMS "Do you like cheese?"
    And I should see "Dan answered a survey question"

  Scenario: User responds to question in a demo with a custom answer act message
    Given the following demo exists:
      | company name | survey answer activity message |
      | CustomCo     | did the thing                  |
    Given the following user exists:
      | name | phone number | demo                   |
      | Fred | +12345551212 | company_name: CustomCo |
    And "Fred" has the password "foobar"
    And the following survey exists:
      | name                   | open_at              | close_at             | demo                   |
      | CustomCo Health Survey | 2011-05-01 11:00 UTC | 2011-05-01 21:00 UTC | company_name: CustomCo |
    And the following survey questions exist:
      | text                                     | index | points | survey                       |
      | What are pants for?                      |     1 |        | name: CustomCo Health Survey |
    And the following survey valid answers exist:
      | value | survey_question           |
      | 1     | text: What are pants for? |
      | 2     | text: What are pants for? |
    Given time is frozen at "2011-05-01 15:00 UTC"
    When "+12345551212" sends SMS "1"
    And I sign in via the login page with "Fred/foobar"
    And I go to the activity page
    Then I should see "Fred did the thing"

  Scenario: User responds to a question with bonus points attached
    Given time is frozen at "2011-05-01 13:00 UTC"
    And the following survey answers exist:
      | user       | survey question |
      | name: Dan  | index: 1        |
    And "+14155551212" sends SMS "1"
    And I sign in via the login page with "Dan/foobar"
    And I go to the activity page
    Then "+14155551212" should have received an SMS "How important is doing what you're told?"
    And I should see "5 pts Dan answered a survey question less than a minute ago"

  Scenario: User responds to question during the window with a bad value that's a single digit
    Given time is frozen at "2011-05-01 15:00 UTC"
    And "+14155551212" sends SMS "3"
    Then "+14155551212" should have received an SMS `Sorry, I don't understand "3" as an answer to that question. Valid answers are: 1, 2.`

    When "+14155551212" sends SMS "123"
    Then "+14155551212" should not have received an SMS including `Sorry, I don't understand "123" as an answer to that question`
    And "+14155551212" should have received an SMS `Sorry, I don't understand what that means. Text "s" to suggest we add what you sent.`

  Scenario: User responds to question during the window with a bad value, but there's an actual rule with that value
    Given time is frozen at "2011-05-01 15:00 UTC"
    And the following rule exists:
      | reply                  | points | demo                | 
      | That's a numeric rule. | 10     | company_name: FooCo | 
    And the following rule value exists:
      | value | rule                          |
      | 200   | reply: That's a numeric rule. |
    And "+14155551212" sends SMS "200"
    Then "+14155551212" should not have received an SMS including "Sorry, I don't understand "200" as an answer to that question."
    And "+14155551212" should have received an SMS including "That's a numeric rule"

  Scenario: User responds to question during the window with a bad value, but there's an actual rule with that value, and the user has finished the survey
    Given time is frozen at "2011-05-01 15:00 UTC"
    And the following rule exists:
      | reply                  | points | demo                |
      | That's a numeric rule. | 10     | company_name: FooCo |
    And the following rule value exists:
      | value | rule                          |
      | 200   | reply: That's a numeric rule. |
    And the following survey answers exist:
      | user       | survey question |
      | name: Dan  | index: 1        |
      | name: Dan  | index: 2        |
      | name: Dan  | index: 3        |
    And "+14155551212" sends SMS "200"
    Then "+14155551212" should not have received an SMS including "Sorry, I don't understand "200" as an answer to that question."
    And "+14155551212" should have received an SMS including "That's a numeric rule"

  Scenario: User responds to question when the survey is not yet open
    Given time is frozen at "2011-05-01 10:59:59 UTC"
    And "+14155551212" sends SMS "1"
    Then "+14155551212" should have received an SMS `Sorry, I don't understand what that means. Text "s" to suggest we add what you sent.`

  Scenario: User resonds to a question after the survey is closed
    Given time is frozen at "2011-05-01 21:00:01 UTC"
    And "+14155551212" sends SMS "1"
    Then "+14155551212" should have received an SMS `Sorry, I don't understand what that means. Text "s" to suggest we add what you sent.`

  Scenario: User responds to last question in the survey
    Given the following survey answers exist:
      | user       | survey question |
      | name: Dan  | index: 1        |
      | name: Dan  | index: 2        |
    And time is frozen at "2011-05-01 15:00 UTC"
    And "+14155551212" sends SMS "4"
    And I sign in via the login page with "Dan/foobar"
    And I go to the activity page
    Then "+14155551212" should have received an SMS "That was the last question. Thanks for completing the survey!"
    And I should see "Dan completed a survey"

  Scenario: User tries to send an answer after all questions are answered
    Given the following survey answers exist:
      | user       | survey question |
      | name: Dan  | index: 1        |
      | name: Dan  | index: 2        |
      | name: Dan  | index: 3        |
    And time is frozen at "2011-05-01 15:00 UTC"
    And "+14155551212" sends SMS "1"
    Then "+14155551212" should have received an SMS "Thanks, we've got all of your survey answers already."

  Scenario: User asks for reminder of last question
    Given the following survey answers exist:
      | user       | survey question |
      | name: Dan  | index: 1        |
      | name: Dan  | index: 2        |  
    And time is frozen at "2011-05-01 15:00 UTC"
    And "+14155551212" sends SMS "LASTQUESTION"
    Then "+14155551212" should have received an SMS "The last question was: How important is doing what you're told?"
