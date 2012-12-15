Feature: User acts via email

  Background:
    Given the following demo exists:
      | name    | 
      | FooCorp |
    Given the following claimed users exist:
      | name | phone number | demo          | points | email             |
      | Dan  | +15087407520 | name: FooCorp | 0      | dan@bigco.com     |
      | Paul | +15088675309 | name: FooCorp | 0      | paul@littleco.com |
      | Fred | +14155551212 | name: FooCorp | 1      | fred@nocobro.com  |
      | Bob  | +18085551212 | name: FooCorp | 3      | bob@bob.net       |
    And "Dan" has the password "foobar"
    And "Paul" has the SMS slug "paul55"
    And "Fred" has the SMS slug "fred666"
    And the following rules exist:
      | points | referral points | reply                     | alltime_limit | demo                  |
      | 2      |                 | Bananas are good for you. |               | name: FooCorp |
      | 5      | 200             | Working out is nice.      |               | name: FooCorp |
      | 20     |                 | Congratulations!          | 2             | name: FooCorp |
      | 8      |                 | So you made toast.        |               | name: FooCorp |
      | 8      |                 | BarCorp rulez!            |               | name: BarCorp |
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

  Scenario: User acts via email
    When "dan@bigco.com" sends email with subject "me tarzan, you jane" and body "ate banana"
    And I sign in via the login page as "Dan/foobar"
    And I go to the acts page
    Then I should see the following act:
      | name | act         | points |
      | Dan  | ate banana  | 2      |

  Scenario: User acts via email for a different act
    When "dan@bigco.com" sends email with subject "love slighty burned bread" and body "made toast"
    And I sign in via the login page as "Dan/foobar"
    And I go to the acts page
    Then I should see the following act:
      | name | act         | points |
      | Dan  | made toast  | 8      |

  Scenario: User acts via email with a strange email body
    When "dan@bigco.com" sends email with subject "love slighty burned bread" and body " made     toast  "
    And I sign in via the login page as "Dan/foobar"
    And I go to the acts page
    Then I should see the following act:
      | name | act         | points |
      | Dan  | made toast  | 8      |

  Scenario: User can send in email commands and have them processed correctly
    When "dan@bigco.com" sends email with subject "me tarzan, you jane" and body "ate banana"
    Then "dan@bigco.com" should receive 1 email
    And "dan@bigco.com" have an email command history with the phrase "Bananas are good for you. Points 2, level 1."
    When "dan@bigco.com" opens the email
    Then I should see "Bananas are good for you. Points 2, level 1." in the email body

    Given a clear email queue

  	When "dan@bigco.com" sends email with subject "me tarzan, you jane" and body "ate banana"
    Then "dan@bigco.com" have an email command history with the phrase "Bananas are good for you. Points 4, level 1."
    When "dan@bigco.com" opens the email
    Then I should see "Bananas are good for you. Points 4, level 1." in the email body

  Scenario: User sends an email with a long body
    When "dan@bigco.com" sends email with subject "me tarzan, you jane" and the following body:
"""
ate banana

This is a confidential communication of TarzanCo (a subsidiary of Burroughs Inc.) If you have received this message and it is not intended for you, please gouge out your eyes and set fire to your computer.

This is not an offer to trade or roll logs. Void where prohibited. Some assembly required. Not intended for children under 65. I'm not wearing any pants. Do you ever wake up in the middle of the night wondering when you're going to die?
"""
    Then "dan@bigco.com" have an email command history with the phrase "Bananas are good for you. Points 2, level 1."

    When I sign in via the login page as "Dan/foobar"
    And I go to the acts page
    Then I should see the following act:
      | name | act         | points |
      | Dan  | ate banana  | 2      |
    When "dan@bigco.com" opens the email
    Then I should see "Bananas are good for you. Points 2, level 1." in the email body

  Scenario: User plays by email in a game with a custom email address
    Given the following demo exists:
      | name | email                  |
      | CustomCo     | custom@playhengage.com |
    And the following claimed user exists:
      | email            | phone number | demo                   |
      | joe@customco.com | +17185551212 | name: CustomCo |
    When "joe@customco.com" sends email with subject "me tarzan, you jane" and body "do good thing"
    And "joe@customco.com" opens the email
    Then they should see the email delivered from "CustomCo <custom@playhengage.com>"
    Then I should see "Good for you" in the email body

  Scenario: User throws a bunch of blank lines in at the top, for God knows what reason
    When "dan@bigco.com" sends email with subject "me tarzan, you jane" and the following body:
    """



    ate banana





    Goddamn I love blank lines






    """

    And I sign in via the login page as "Dan/foobar"
    Then I should see the following act:
      | name | act         | points |
      | Dan  | ate banana  | 2      |

  Scenario: User sends email with blank body and gets a reasonable response
    When "dan@bigco.com" sends email with subject "" and body ""
    Then "dan@bigco.com" should receive 1 email
    When "dan@bigco.com" opens the email
    Then I should see "We got your email, but it looks like the body of it was blank. Please put your command in the first line of the email body." in the email body

  Scenario: Claimed user in a game with self-inviting domains can play by email
    Given the following demo exists:
      | name     |
      | InviteCo |
    And the following claimed user exists:
      | name     | email        | demo           |
      | John Boy | john@foo.com | name: InviteCo |

    And "john@foo.com" sends email with subject "hey" and body "do good thing"
    And DJ cranks 5 times

    Then "john@foo.com" should receive 1 email
    When "john@foo.com" opens the email
    Then I should see "Good for you" in the email body
    But I should not see "Thanks for requesting an invite to play InviteCo." in the email body
