Feature: Following and follower lists

  Background:
    Given the following users exist:
      | name    | points |
      | Arturo  | 50     |
      | Bertram | 20     |
      | Colby   | 35     |
      | Dirk    | 90     |
    And the following friendships exist:
      | user         | friend        |
      | name: Arturo | name: Bertram |
      | name: Arturo | name: Dirk    |
      | name: Colby  | name: Arturo  |
      | name: Colby  | name: Bertram |
      | name: Dirk   | name: Arturo  |
      | name: Dirk   | name: Bertram |
      | name: Dirk   | name: Colby   |
    And "Arturo" has the password "foo"
    And I sign in via the login page as "Arturo/foo"
    And I go to the friends page

  Scenario: Follower list
    Then I should see these followers:
      | name    | button_type |
      | Colby   | follow      |
      | Dirk    | unfollow    |

  Scenario: Following list
    Then I should see these people I am following:
      | name    | button_type |
      | Bertram | unfollow    |
      | Dirk    | unfollow    |

  Scenario: Unollowing user from follower list
    When I unfollow "Dirk"
    Then I should be on the friends page
    And I should see these people I am following:
      | name    | button_type |
      | Bertram | unfollow    |
    And I should see these followers:
      | name    | button_type |
      | Colby   | follow      |
      | Dirk    | follow      |

  Scenario: Following user from following list
    When I press "Follow"
    Then I should be on the friends page
    And I should see these people I am following:
      | name    | button_type |
      | Bertram | unfollow    |
      | Colby   | unfollow    |
      | Dirk    | unfollow    |
    And I should see these followers:
      | name    | button_type |
      | Colby   | unfollow    |
      | Dirk    | unfollow    |
