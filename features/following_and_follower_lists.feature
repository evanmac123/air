Feature: Following and follower lists

  Background:
    Given the following users exist:
      | name    | points | demo                              |
      | Arturo  | 50     | company_name: Amalgamated Widgets |
      | Bertram | 20     | company_name: Amalgamated Widgets |
      | Colby   | 35     | company_name: Amalgamated Widgets |
      | Dirk    | 90     | company_name: Amalgamated Widgets |
      | Evan    | 44     | company_name: Synthetic Persons   |
      | Fred    | 44     | company_name: Synthetic Persons   |
    And the following friendships exist:
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
    And "Arturo" has the password "foo"
    And I sign in via the login page as "Arturo/foo"
    And I go to the friends page

  Scenario: Follower list
    Then I should see these followers:
      | name    | button_type  |
      | Colby   | be a fan      |
      | Dirk    | de-fan    |
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
      | Bertram | de-fan    |
    And I should see these followers:
      | name    | button_type  |
      | Colby   | be a fan      |
      | Dirk    | be a fan      |

  Scenario: Following user from following list
    When I press "Be a fan"
    Then I should be on the friends page
    And I should see these people I am following:
      | name    | button_type  |
      | Bertram | de-fan    |
      | Colby   | de-fan    |
      | Dirk    | de-fan    |
    And I should see these followers:
      | name    | button_type  |
      | Colby   | de-fan    |
      | Dirk    | de-fan    |
