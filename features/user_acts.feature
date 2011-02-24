Feature: User acts

  Background:
    Given the following demo exists:
      | company_name | victory_threshold |
      | FooCorp      | 50                |
    Given the following user exists:
      | name | phone number | demo                  |
      | Dan  | +15087407520 | company_name: FooCorp |
    And "Dan" has the password "foo"
    And a key exists with a name of "ate"
    And the following rule exists:
      | key       | value  | points | reply                     |
      | name: ate | banana | 2      | Bananas are good for you. |

  Scenario: User acts
    When "+15087407520" sends SMS "ate banana"
    And I sign in via the login page as "Dan/foo"
    And I go to the acts page
    Then I should see the following act:
      | name | act         | points |
      | Dan  | ate banana  | 2      |

  Scenario: User acts, with a trailing period
    When "+15087407520" sends SMS "ate banana."
    And I sign in via the login page as "Dan/foo"
    And I go to the acts page
    Then I should see the following act:
      | name | act         | points |
      | Dan  | ate banana  | 2      |
  
  Scenario: User acts, with trailing whitespace
    When "+15087407520" sends SMS "ate banana    "
    And I sign in via the login page as "Dan/foo"
    And I go to the acts page
    Then I should see the following act:
      | name | act         | points |
      | Dan  | ate banana  | 2      |

  Scenario: Returning to acts page from someone else's profile
    Given the following user exists:
      | name |
      | Fred |
    When I sign in via the login page
    And I go to the profile page for "Fred"
    And I follow "Back To Activity Stream"
    Then I should be on the activity page

  Scenario: User gets a reply from the game on acting
    When "+15087407520" sends SMS "ate banana"
    Then "+15087407520" should have received an SMS "Bananas are good for you. You have 2 out of 50 points."
