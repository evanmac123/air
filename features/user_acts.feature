Feature: User acts

  Background:
    Given the following demo exists:
      | company_name | victory_threshold |
      | FooCorp      | 50                |
    Given the following users exist:
      | name | phone number | demo                  | points | ranking |
      | Dan  | +15087407520 | company_name: FooCorp | 0      | 3       |
      | Paul | +15088675309 | company_name: FooCorp | 0      | 3       |
      | Fred | +14155551212 | company_name: FooCorp | 1      | 2       |
      | Bob  | +18085551212 | company_name: FooCorp | 3      | 1       |
    And "Dan" has the password "foo"
    And the following rules exist:
      | key          | value  | points | referral points | reply                     | alltime_limit | 
      | name: ate    | banana | 2      |                 | Bananas are good for you. |               |
      | name: worked | out    | 5      | 200             | Working out is nice.      |               |
      | name: saw    | poster | 20     |                 | Congratulations!          | 2             |
    And the following coded rule exists:
      | value | points | description                                     | reply                  |
      | ZXCVB | 15     | Looked at our poster about healthful practices. | Good show. +15 points. |
    And time is frozen at "2011-05-23 00:00 UTC"

  Scenario: User acts via SMS
    When "+15087407520" sends SMS "ate banana"
    And I sign in via the login page as "Dan/foo"
    And I go to the acts page
    Then I should see the following act:
      | name | act         | points |
      | Dan  | ate banana  | 2      |

  #Scenario: User acts via the website
  #  When I sign in via the login page as "Dan/foo"
  #  And I go to the acts page
  #  And I enter the act "ate banana" via the dropdown
  #  And I enter the act "worked out" via the dropdown
  #  Then I should see the following acts:
  #    | name | act         | points |
  #    | Dan  | ate banana  | 2      |
  #    | Dan  | worked out  | 5      |
  #  And I should see the success message "Working out is nice. You have 7 out of 50 points."

  Scenario: User enters bad act via the website
    When I sign in via the login page as "Dan/foo"
    And I enter the act code "worked banana"
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

  Scenario: User gets a reply from the game on acting with points and ranking information
    When "+15087407520" sends SMS "ate banana"
    Then "+15087407520" should have received an SMS "Bananas are good for you. Points 2/50, rank 2/4."

  Scenario: User can only get credit for rules up to their limits
    When "+15087407520" sends SMS "saw poster"
    And "+15087407520" sends SMS "saw poster"
    And "+15087407520" sends SMS "saw poster"
    And I sign in via the login page as "Dan/foo"
    And I go to the acts page
    Then I should see "Dan 40 points"
    And "+15087407520" should have received an SMS "Congratulations! Points 20/50, rank 1/4."
    And "+15087407520" should have received an SMS "Congratulations! Points 40/50, rank 1/4."
    And "+15087407520" should not have received an SMS "Congratulations! Points 60/50, rank 1/4."
    And "+15087407520" should have received an SMS "Sorry, you've already done that action."

  Scenario: Another user gets points for referring you to a command
    When "+15087407520" sends SMS "ate banana paul"
    And "+15087407520" sends SMS "worked out fred"
    And I sign in via the login page as "Dan/foo"
    And I go to the acts page
    Then I should see "Paul 1 point"
    And I should see "Fred 201 points"
    And I should see "Dan ate banana (thanks Paul for the referral) less than a minute ago +2 points"
    And I should see "Dan worked out (thanks Fred for the referral) less than a minute ago +5 points"
    And I should see "Paul told Dan about the ate banana command less than a minute ago +1 point"
    And I should see "Fred told Dan about the worked out command less than a minute ago +200 points"
    And "+15088675309" should have received an SMS "Thanks for referring Dan to the ate banana command. Points 1/50, rank 2/4."
    And "+14155551212" should have received an SMS "Thanks for referring Dan to the worked out command. Points 201/50, rank 1/4."

  Scenario: A helpful error message if you say a nonexistent user referred you
    When "+15087407520" sends SMS "ate banana mrnobody"
    And I sign in via the login page as "Dan/foo"
    And I go to the acts page
    Then I should see "Dan 0 points"
    And "+15087407520" should have received an SMS "We understood what you did, but not the user who referred you. Perhaps you could have them check their unique ID with the myid command?"
