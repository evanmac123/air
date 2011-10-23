Feature: User acts via email

  Background:
    Given the following demo exists:
      | company_name | victory_threshold |
      | FooCorp      | 50                |
    Given the following users exist:
      | name | phone number | demo                  | points | ranking | email             |
      | Dan  | +15087407520 | company_name: FooCorp | 0      | 3       | dan@bigco.com     |
      | Paul | +15088675309 | company_name: FooCorp | 0      | 3       | paul@littleco.com |
      | Fred | +14155551212 | company_name: FooCorp | 1      | 2       | fred@nocobro.com  |
      | Bob  | +18085551212 | company_name: FooCorp | 3      | 1       | bob@bob.net       |
    And "Dan" has the password "foo"
    And "Paul" has the SMS slug "paul55"
    And "Fred" has the SMS slug "fred666"
    And the following rules exist:
      | points | referral points | reply                     | alltime_limit | demo                  |
      | 2      |                 | Bananas are good for you. |               | company_name: FooCorp |
      | 5      | 200             | Working out is nice.      |               | company_name: FooCorp |
      | 20     |                 | Congratulations!          | 2             | company_name: FooCorp |
      | 8      |                 | So you made toast.        |               | company_name: FooCorp |
      | 8      |                 | BarCorp rulez!            |               | company_name: BarCorp |
      | 10     |                 | Good for you.             |               |                       |
    And the following rule values exist:
      | value         | rule                             |
      | ate banana    | reply: Bananas are good for you. |
      | ate bananas   | reply: Bananas are good for you. |
      | worked out    | reply: Working out is nice.      |
      | saw poster    | reply: Congratulations!          |
      | made toast    | reply: So you made toast.        |
      | up the bar    | reply: BarCorp rulez!            |
      | do good thing | reply: Good for you.             |
    And the following forbidden rule values exist:
      | value       |
      | was naughty | 
    And time is frozen at "2011-05-23 00:00 UTC"

  Scenario: User acts via EMAIL
    When "dan@bigco.com" sends EMAIL with subject "me tarzan, you jane" and body "ate banana"
    And I sign in via the login page as "Dan/foo"
    And I go to the acts page
    Then I should see the following act:
      | name | act         | points |
      | Dan  | ate banana  | 2      |

