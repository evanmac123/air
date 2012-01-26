Feature: Acts can be kept out of the user feed

  Scenario: Rule with blank description shows no trace in the feed
    Given the following demo exists:
      | name |
      | FooCo        |
    And the following user exists:
      | name | phone number | demo                |
      | Phil | +14155551212 | name: FooCo |
    And "Phil" has the password "foobar"
    And the following rules exist:
      | reply               | description   | points | demo                |
      | You acted visibly   | acted visibly | 5      | name: FooCo |
      | You acted invisibly |               | 7      | name: FooCo |
    And the following rule values exist:
      | value           | rule                       |
      | acted visibly   | reply: You acted visibly   |
      | acted invisibly | reply: You acted invisibly |
    When "+14155551212" sends SMS "acted visibly"
    And "+14155551212" sends SMS "acted invisibly"
    Then "+14155551212" should have received an SMS including "You acted visibly"
    And "+14155551212" should have received an SMS including "You acted invisibly"

    When I sign in via the login page with "Phil/foobar"
    And I go to the activity page
    Then I should see "Phil acted visibly"
    # And I should see "12points"
    Then I should not see "7 pts"
    And I should not see "acted invisibly"

    When I go to the profile page for "Phil"
    Then I should see "Phil acted visibly"
    But I should not see "7 pts"
    And I should not see "acted invisibly"
