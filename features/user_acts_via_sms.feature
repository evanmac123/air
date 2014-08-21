Feature: User acts

  Background:
    Given the following demo exists:
      | name    |
      | FooCorp |
      | BarCorp |
    Given the following claimed users exist:
      | name | phone number | privacy level | demo          | Points |
      | Dan  | +15087407520 | everybody     | name: FooCorp | 0      |
      | Paul | +15088675309 | everybody     | name: FooCorp | 0      |
      | Fred | +14155551212 | everybody     | name: FooCorp | 1      |
      | Bob  | +18085551212 | everybody     | name: FooCorp | 3      |
      | Sven | +17145551212 | everybody     | name: BarCorp | 5      |
    And "Dan" has the password "foobar"
    And "Sven" has the password "foobar"
    And "Paul" has the SMS slug "paul55"
    And "Fred" has the SMS slug "fred666"
    And "Sven" has the SMS slug "sven"
    And the following rules exist:
      | Points | referral Points | reply                     | alltime_limit | demo          |
      | 2      |                 | Bananas are good for you. |               | name: FooCorp |
      | 5      | 200             | Working out is nice.      |               | name: FooCorp |
      | 20     |                 | Congratulations!          | 2             | name: FooCorp |
      | 8      |                 | So you made toast.        |               | name: FooCorp |
      | 8      |                 | BarCorp rulez!            |               | name: BarCorp |
      | 10     |                 | Good for you.             |               |               |
      |        |                 | Weak.                     |               | name: FooCorp |
    And the following rule values exist:
      | value         | rule                             |
      | ate banana    | reply: Bananas are good for you. |
      | ate bananas   | reply: Bananas are good for you. |
      | worked out    | reply: Working out is nice.      |
      | saw poster    | reply: Congratulations!          |
      | made toast    | reply: So you made toast.        |
      | up the bar    | reply: BarCorp rulez!            |
      | do good thing | reply: Good for you.             |
      | weak          | reply: Weak.                     |
    And time is frozen at "2011-05-23 00:00 UTC"

  Scenario: User acts via SMS
    When "+15087407520" sends SMS "ate banana"
    And I sign in via the login page as "Dan/foobar"
    And I go to the acts page
    Then I should see the following act:
      | name | act         | Points |
      | Dan  | ate banana  | 2      |

  Scenario: User doesn't see acts from another demo
    When "+15087407520" sends SMS "ate banana"
    And I sign in via the login page as "Dan/foobar"
    Then I should see the following act:
      | name | act         | Points |
      | Dan  | ate banana  | 2      |
    When I sign in via the login page as "Sven/foobar"
    Then I should be on the activity page with HTML forced
    But I should not see "ate banana"

  Scenario: User can use any rule value to refer to a rule
    When "+15087407520" sends SMS "ate banana"
    And "+15087407520" sends SMS "ate bananas"
    Then "+15087407520" should have received SMS "Bananas are good for you. Points 2/20, Tix 0."
    And "+15087407520" should have received SMS "Bananas are good for you. Points 4/20, Tix 0."

  Scenario: User acts, with a trailing period
    When "+15087407520" sends SMS "ate banana."
    And I sign in via the login page as "Dan/foobar"
    And I go to the acts page
    Then I should see the following act:
      | name | act         | Points |
      | Dan  | ate banana  | 2      |

  Scenario: User acts, with trailing whitespace
    When "+15087407520" sends SMS "ate banana    "
    And I sign in via the login page as "Dan/foobar"
    And I go to the acts page
    Then I should see the following act:
      | name | act         | Points |
      | Dan  | ate banana  | 2      |

  Scenario: User tries to act with an act belonging to a different demo
    When "+15087407520" sends SMS "up the bar"
    Then "+15087407520" should have received an SMS including "Sorry, I don't understand what "up the bar" means."

  Scenario: User can act with a standard playbook rule (belonging to no demo) if demo supports it
    Given the following demo exists:
      | name         | use_standard_playbook |
      | CustomCo     | false                 |
    And the following claimed user exists:
      | phone_number | demo           |
      | +14152613077 | name: CustomCo |
    And the following rule exists:
      | demo           | reply                     |
      | name: CustomCo | Headcheese is disgusting. |
    And the following rule value exists:
      | value          | rule                             |
      | ate headcheese | reply: Headcheese is disgusting. |
    When "+15087407520" sends SMS "do good thing"
    And I sign in via the login page as "Dan/foobar"
    And I go to the acts page
    Then "+15087407520" should have received an SMS including "Good for you."
    And I should see the following act:
      | name | act                             | Points |
      | Dan  | do good thing  | 10     |
    When "+14152613077" sends SMS "do good thing"
    Then "+14152613077" should not have received an SMS including "Good for you."
    When "+14152613077" sends SMS "ate headcheese"
    Then "+14152613077" should have received an SMS including "Headcheese is disgusting."

  Scenario: User gets a reply from the game on acting with Points and ranking information
    When "+15087407520" sends SMS "ate banana"
    Then "+15087407520" should have received an SMS "Bananas are good for you. Points 2/20, Tix 0."

  Scenario: User achieves part of a goal by acting
    Given the following goals exist:
      | name              | demo                  |
      | deadly sins       | name: FooCorp |
      | redeeming virtues | name: FooCorp |
    And the following rules exist:
      | reply               | Points | demo                  |
      | Lust woo!           | 2      | name: FooCorp |
      | Pride boo!          | 5      | name: FooCorp |
      | Envy who?           | 6      | name: FooCorp |
      | Charity good for u. | 11     | name: FooCorp |
      | So is diligence too | 15     | name: FooCorp |
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
    Then "+15087407520" should have received SMS "Lust woo! Deadly sins 1/3, Points 2/20, Tix 0."

    When "+15087407520" sends SMS "lust"
    Then "+15087407520" should have received SMS "Lust woo! Deadly sins 1/3, Points 4/20, Tix 0."

    When "+15087407520" sends SMS "charity"
    Then "+15087407520" should have received SMS "Charity good for u. Redeeming virtues 1/2, Points 15/20, Tix 0."

    When "+15088675309" sends SMS "diligence"
    Then "+15088675309" should have received SMS "So is diligence too Redeeming virtues 1/2, Points 15/20, Tix 0."

    When "+15087407520" sends SMS "diligence"
    Then "+15087407520" should have received SMS "So is diligence too Redeeming virtues 2/2, Points 10/20, Tix 1."

    When "+15087407520" sends SMS "pride"
    Then "+15087407520" should have received SMS "Pride boo! Deadly sins 2/3, Points 15/20, Tix 1."

    When "+15087407520" sends SMS "lust"
    Then "+15087407520" should have received SMS "Lust woo! Deadly sins 2/3, Points 17/20, Tix 1."

  Scenario: User can only get credit for rules up to their limits
    When "+15087407520" sends SMS "saw poster"
    And "+15087407520" sends SMS "saw poster"
    And "+15087407520" sends SMS "saw poster"
    And "+15087407520" should have received an SMS "Congratulations! Points 0/20, Tix 1."
    And "+15087407520" should have received an SMS "Congratulations! Points 0/20, Tix 2."
    And "+15087407520" should have received an SMS "Sorry, you've already done that action."

  Scenario: Act with 0 Points should not mention that
    Given the following act exists:
      | text         | inherent Points | user        | 
      | did not much | 0               | name: Dan   | 
    When I sign in via the login page with "Dan/foobar"
    Then I should be on the activity page with HTML forced
    And I should see "Dan did not much"
    But I should not see "0 pts"

  Scenario: User acts in a demo that doesn't use post-act summaries
    Given the demo "FooCorp" doesn't use post-act summaries
    When "+15087407520" sends SMS "ate banana"
    Then "+15087407520" should have received an SMS "Bananas are good for you."
