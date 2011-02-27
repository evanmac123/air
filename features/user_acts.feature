Feature: User acts

  Background:
    Given the following demo exists:
      | company_name | victory_threshold |
      | FooCorp      | 50                |
    Given the following user exists:
      | name | phone number | demo                  |
      | Dan  | +15087407520 | company_name: FooCorp |
    And "Dan" has the password "foo"
    And the following rules exist:
      | key          | value  | points | reply                     |
      | name: ate    | banana | 2      | Bananas are good for you. |
      | name: worked | out    | 5      | Working out is nice.      |
    And the following coded rule exists:
      | value | points | description                                     | reply                  |
      | ZXCVB | 15     | Looked at our poster about healthful practices. | Good show. +15 points. |

  Scenario: User acts via SMS
    When "+15087407520" sends SMS "ate banana"
    And I sign in via the login page as "Dan/foo"
    And I go to the acts page
    Then I should see the following act:
      | name | act         | points |
      | Dan  | ate banana  | 2      |

  Scenario: User acts via the website
    When I sign in via the login page as "Dan/foo"
    And I go to the acts page
    And I enter the act "ate banana" via the dropdown
    And I enter the act "worked out" via the dropdown
    Then I should see the following acts:
      | name | act         | points |
      | Dan  | ate banana  | 2      |
      | Dan  | worked out  | 5      |
    And I should see the success message "Working out is nice. You have 7 out of 50 points."

  Scenario: User enters bad act via the website
    When I sign in via the login page as "Dan/foo"
    And I enter the act "worked banana" via the dropdown
    Then I should see the error "We understand worked but not banana. Try: worked out"

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

  Scenario: User acts with a coded rule
    When "+15087407520" sends SMS "ZXCVB"
    And I sign in via the login page as "Dan/foo"
    And I go to the acts page
    Then I should see the following act:
      | name | act                                             | points |
      | Dan  | Looked at our poster about healthful practices. | 15     |

  Scenario: User enters a coded rule into the website
    When I sign in via the login page as "Dan/foo"
    And I go to the acts page
    And I enter the act code "zxcvb"
    Then I should see the following act:
      | name | act                                             | points |
      | Dan  | Looked at our poster about healthful practices. | 15     |
    And I should see the success message "Good show. +15 points."

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
