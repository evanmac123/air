Feature: Following and follower lists

  Background:
    Given the following users exist:
      | name    | points | demo                              | phone number |
      | Arturo  | 50     | name: Amalgamated Widgets | +14155551212 |
      | Bertram | 20     | name: Amalgamated Widgets | +14155551213 |
      | Colby   | 35     | name: Amalgamated Widgets | +14155551214 |
      | Dirk    | 90     | name: Amalgamated Widgets | +14155551215 |
      | Evan    | 44     | name: Synthetic Persons   | +14155551216 |
      | Fred    | 44     | name: Synthetic Persons   | +14155551217 |
    And the following users exist:
      | name    | demo                              |
      | Gerald  | name: Amalgamated Widgets |
      | Hector  | name: Amalgamated Widgets |
      | Ignatz  | name: Amalgamated Widgets |
      | Jerome  | name: Amalgamated Widgets |
      | Keith   | name: Amalgamated Widgets |
      | Leslie  | name: Amalgamated Widgets |
      | Maurice | name: Amalgamated Widgets |
      | Nolan   | name: Amalgamated Widgets |
    And the following accepted friendships exist:
      | user         | friend        |
      | name: Arturo | name: Bertram |
      | name: Arturo | name: Dirk    |
      | name: Arturo | name: Evan    |
      | name: Colby  | name: Arturo  |
      | name: Colby  | name: Bertram |
      | name: Dirk   | name: Arturo  |
      | name: Dirk   | name: Bertram |
      | name: Dirk   | name: Colby   |
      | name: Fred   | name: Arturo  |
    And "Arturo" has the password "foobar"
    And I sign in via the login page as "Arturo/foobar"
    And I go to the friends page

  Scenario: Follower list
    Then I should see these followers:
      | name    | button_type  |
      | Colby   | be a fan     |
      | Dirk    | de-fan       |
    And I should not see "Fred"

  Scenario: Following list
    Then I should see these people I am following:
      | name    | button_type  |
      | Bertram | de-fan    |
      | Dirk    | de-fan    |
    And I should not see "Evan"

  Scenario: Unollowing user from follower list
    When I unfollow "Dirk"
    Then I should be on the friends page
    And I should see these people I am following:
      | name    | button_type  |
      | Bertram | de-fan       |
    And I should see these followers:
      | name    | button_type   |
      | Colby   | be a fan      |
      | Dirk    | be a fan      |

  Scenario: Following user from following list
    When I fan "Colby"
    And "+14155551214" sends SMS "yes"
    And I go to the friends page
    And I should see these people I am following:
      | name    | button_type  |
      | Bertram | de-fan       |
      | Colby   | de-fan       |
      | Dirk    | de-fan       |
    And I should see these followers:
      | name    | button_type  |
      | Colby   | de-fan       |
      | Dirk    | de-fan       |

  @javascript @slow
  Scenario: User sees more of their following list
    Given the following accepted friendships exist:
      | user         | friend        |
      | name: Arturo | name: Gerald  |
      | name: Arturo | name: Hector  |
      | name: Arturo | name: Ignatz  |
      | name: Arturo | name: Jerome  |
      | name: Arturo | name: Keith   |
      | name: Arturo | name: Leslie  |
      | name: Arturo | name: Maurice |
      | name: Arturo | name: Nolan   |
    When I go to the friends page
    Then I should see these people I am following:
      | name    | button_type |
      | Nolan   | de-fan      |
      | Maurice | de-fan      |
      | Leslie  | de-fan      |
      | Keith   | de-fan      |
    And I should not see "Gerald"
    And I should not see "Hector"
    And I should not see "Ignatz"
    And I should not see "Jerome"
    When I press the button to see more people I am following
    Then I should see these people I am following:
      | name    | button_type |
      | Nolan   | de-fan      |
      | Maurice | de-fan      |
      | Leslie  | de-fan      |
      | Keith   | de-fan      |
      | Gerald  | de-fan      |
      | Hector  | de-fan      |
      | Ignatz  | de-fan      |
      | Jerome  | de-fan      |
      | Dirk    | de-fan      |
      | Bertram | de-fan      |

  @javascript @slow
  Scenario: User sees more of their follower list
    Given the following accepted friendships exist:
      | user          | friend       |
      | name: Gerald  | name: Arturo | 
      | name: Hector  | name: Arturo | 
      | name: Ignatz  | name: Arturo | 
      | name: Jerome  | name: Arturo | 
      | name: Keith   | name: Arturo | 
      | name: Leslie  | name: Arturo | 
      | name: Maurice | name: Arturo | 
      | name: Nolan   | name: Arturo | 
    When I go to the friends page
    Then I should see these followers:
      | name    | button_type |
      | Nolan   | be a fan    |
      | Maurice | be a fan    |
      | Leslie  | be a fan    |
      | Keith   | be a fan    |
    And I should not see "Gerald"
    And I should not see "Hector"
    And I should not see "Ignatz"
    And I should not see "Jerome"
    When I press the button to see more followers    
    Then I should see these followers:
      | name    | button_type |
      | Nolan   | be a fan    |
      | Maurice | be a fan    |
      | Leslie  | be a fan    |
      | Keith   | be a fan    |
      | Gerald  | be a fan    |
      | Hector  | be a fan    |
      | Ignatz  | be a fan    |
      | Jerome  | be a fan    |
      | Dirk    | de-fan      |
      | Colby   | be a fan    |
