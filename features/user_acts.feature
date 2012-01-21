Feature: User acts

  Background:
    Given the following demo exists:
      | company_name | victory_threshold |
      | FooCorp      | 50                |
    Given the following claimed users exist:
      | name | phone number | demo                  | points | ranking |
      | Dan  | +15087407520 | company_name: FooCorp | 0      | 3       |
      | Paul | +15088675309 | company_name: FooCorp | 0      | 3       |
      | Fred | +14155551212 | company_name: FooCorp | 1      | 2       |
      | Bob  | +18085551212 | company_name: FooCorp | 3      | 1       |
    And "Dan" has the password "foobar"
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

  Scenario: User acts via SMS
    When "+15087407520" sends SMS "ate banana"
    And I sign in via the login page as "Dan/foobar"
    And I go to the acts page
    Then I should see the following act:
      | name | act         | points |
      | Dan  | ate banana  | 2      |

  Scenario: User can use any rule value to refer to a rule
    When "+15087407520" sends SMS "ate banana"
    And "+15087407520" sends SMS "ate bananas"
    Then "+15087407520" should have received SMS "Bananas are good for you. Points 2/50, rank 3/4."
    And "+15087407520" should have received SMS "Bananas are good for you. Points 4/50, rank 3/4."

  Scenario: User enters bad act via the website
    When I sign in via the login page as "Dan/foobar"
    And I enter the act code "chainsaw massacred"
    Then I should see the error "Sorry, I don't understand what that means."

  Scenario: User acts, with a trailing period
    When "+15087407520" sends SMS "ate banana."
    And I sign in via the login page as "Dan/foobar"
    And I go to the acts page
    Then I should see the following act:
      | name | act         | points |
      | Dan  | ate banana  | 2      |

  Scenario: User acts, with trailing whitespace
    When "+15087407520" sends SMS "ate banana    "
    And I sign in via the login page as "Dan/foobar"
    And I go to the acts page
    Then I should see the following act:
      | name | act         | points |
      | Dan  | ate banana  | 2      |

  Scenario: User tries to act with an act belonging to a different demo
    When "+15087407520" sends SMS "up the bar"
    Then "+15087407520" should have received an SMS including "Sorry, I don't understand what that means."

  Scenario: User can act with a standard playbook rule (belonging to no demo) if demo supports it
    Given the following demo exists:
      | company name | use_standard_playbook |
      | CustomCo     | false                 |
    And the following user exists:
      | phone_number | demo                   |
      | +14152613077 | company_name: CustomCo |
    And the following rule exists:
      | demo                   | reply                     |
      | company_name: CustomCo | Headcheese is disgusting. |
    And the following rule value exists:
      | value          | rule                             |
      | ate headcheese | reply: Headcheese is disgusting. |
    When "+15087407520" sends SMS "do good thing"
    And I sign in via the login page as "Dan/foobar"
    And I go to the acts page
    Then "+15087407520" should have received an SMS including "Good for you."
    And I should see the following act:
      | name | act                             | points |
      | Dan  | do good thing  | 10     |
    When "+14152613077" sends SMS "do good thing"
    Then "+14152613077" should not have received an SMS including "Good for you."
    When "+14152613077" sends SMS "ate headcheese"
    Then "+14152613077" should have received an SMS including "Headcheese is disgusting."

  Scenario: User gets a reply from the game on acting with points and ranking information
    When "+15087407520" sends SMS "ate banana"
    Then "+15087407520" should have received an SMS "Bananas are good for you. Points 2/50, rank 3/4."

  Scenario: User achieves part of a goal by acting
    Given the following goals exist:
      | name              | demo                  |
      | deadly sins       | company_name: FooCorp |
      | redeeming virtues | company_name: FooCorp |
    And the following rules exist:
      | reply               | points | demo                  |
      | Lust woo!           | 2      | company_name: FooCorp |
      | Pride boo!          | 5      | company_name: FooCorp |
      | Envy who?           | 6      | company_name: FooCorp |
      | Charity good for u. | 11     | company_name: FooCorp |
      | So is diligence too | 15     | company_name: FooCorp |
    And rule "Lust woo!" is associated with goal "deadly sins"
    And rule "Pride boo!" is associated with goal "deadly sins"
    And rule "Envy who?" is associated with goal "deadly sins"
    And rule "Charity good for u." is associated with goal "redeeming virtues"
    And rule "So is diligence too" is associated with goal "redeeming virtues"
    And the following rule values exist:
      | value     | rule                       |
      | lust      | reply: Lust woo!           |
      | pride     | reply: Pride boo!          |
      | envy      | reply: Envy who?           |
      | charity   | reply: Charity good for u. |
      | diligence | reply: So is diligence too |

    When "+15087407520" sends SMS "lust"
    Then "+15087407520" should have received SMS "Lust woo! Deadly sins 1/3, points 2/50, rank 3/4."

    When "+15087407520" sends SMS "lust"
    Then "+15087407520" should have received SMS "Lust woo! Deadly sins 1/3, points 4/50, rank 3/4."

    When "+15087407520" sends SMS "charity"
    Then "+15087407520" should have received SMS "Charity good for u. Redeeming virtues 1/2, points 15/50, rank 3/4."

    When "+15088675309" sends SMS "diligence"
    Then "+15088675309" should have received SMS "So is diligence too Redeeming virtues 1/2, points 15/50, rank 3/4."

    When "+15087407520" sends SMS "diligence"
    Then "+15087407520" should have received SMS "So is diligence too Redeeming virtues 2/2, points 30/50, rank 3/4."

    When "+15087407520" sends SMS "pride"
    Then "+15087407520" should have received SMS "Pride boo! Deadly sins 2/3, points 35/50, rank 3/4."

    When "+15087407520" sends SMS "lust"
    Then "+15087407520" should have received SMS "Lust woo! Deadly sins 2/3, points 37/50, rank 3/4."

  Scenario: User tries an act that we've specifically forbidden
    When "+15087407520" sends SMS "was naughty"
    Then "+15087407520" should have received an SMS "Sorry, that's not a valid command."

  Scenario: Acts allowed in demo take precedence over forbidden acts
    Given the following demo exists:
      | company name | victory threshold |
      | NaughtyCo    | 200               |
    And the following user exists:
      | phone number | demo                    |
      | +13025551212 | company_name: NaughtyCo |
    And the following rule exists:
      | reply            | points | demo                    |
      | Naughty is good. | 10     | company_name: NaughtyCo |
    And the following rule value exists:
      | value       | rule                    |
      | was naughty | reply: Naughty is good. |
    When "+13025551212" sends SMS "was naughty"
    Then "+13025551212" should have received an SMS including "Naughty is good. Points 10/200"

  Scenario: User can only get credit for rules up to their limits
    When "+15087407520" sends SMS "saw poster"
    And "+15087407520" sends SMS "saw poster"
    And "+15087407520" sends SMS "saw poster"
    # And I sign in via the login page as "Dan/foobar"
    # And I go to the acts page
    # Then I should see "Dan 40 pts"
    And "+15087407520" should have received an SMS "Congratulations! Points 20/50, rank 3/4."
    And "+15087407520" should have received an SMS "Congratulations! Points 40/50, rank 3/4."
    But "+15087407520" should not have received an SMS including "Congratulations! Points 60/50"
    And "+15087407520" should have received an SMS "Sorry, you've already done that action."

  Scenario: Another user gets points for referring you to a command
    When "+15087407520" sends SMS "ate banana paul55"
    And "+15087407520" sends SMS "worked out fred666"
    And DJ cranks 10 times
    And I sign in via the login page as "Dan/foobar"
    And I go to the acts page
    # Then I should see "Paul 1 pt"
    # And I should see "Fred 201 pts"
    And I should see "2 pts Dan ate banana (thanks Paul for the referral) less than a minute"
    And I should see "5 pts Dan worked out (thanks Fred for the referral) less than a minute"
    And I should see "1 pt Paul told Dan about a command less than a minute ago"
    And I should see "200 pts Fred told Dan about a command less than a minute ago"
    And "+15088675309" should have received an SMS "Thanks for referring Dan to the ate banana command. Points 1/50, rank 3/4."
    And "+14155551212" should have received an SMS "Thanks for referring Dan to the worked out command. Points 201/50, rank 2/4."

  Scenario: A helpful error message if you say a nonexistent user referred you
    When "+15087407520" sends SMS "ate banana mrnobody"
    # And I sign in via the login page as "Dan/foobar"
    # And I go to the acts page
    # Then I should see "Dan 0 pts"
    And "+15087407520" should have received an SMS "We understood what you did, but not the user who referred you. Perhaps you could have them check their user ID with the MYID command?"

  Scenario: A helpful and slightly snarky error message if you say you referred yourself
    Given "Dan" has the SMS slug "dan4444"
    When "+15087407520" sends SMS "ate banana dan4444"
    # And I sign in via the login page as "Dan/foobar"
    # And I go to the acts page
    # Then I should see "Dan 0 pts"
    And "+15087407520" should have received an SMS "Now now. It wouldn't be fair to try to get extra points by referring yourself."
