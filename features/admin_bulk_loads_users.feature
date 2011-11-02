Feature: Admin bulk loads users

  Background:
    Given the following demo exists:
      | company name | credit_game_referrer_threshold | game_referrer_bonus |
      | H Engage     | 60                             | 2000                |
    And the following user exists:
      | name | is site admin |
      | Phil | true          |
    And "Phil" has the password "foo"
    And I sign in via the login page with "Phil/foo"
    And I go to the user bulk upload page for "H Engage"

  Scenario: Admin uploads users with email addresses
    When I enter the following into the bulk information area:
"""
John Smith,jsmith@example.com
Bob Jones,bjones@example.com
Fred Robinson,frobinson@example.com
"""
    And I press "Upload Users"
    Then I should see "Successfully loaded 3 users"
    When I go to the admin "H Engage" demo page
    And I follow "J"
    Then I should see "John Smith, jsmith@example.com (jsmith)"

    When I follow "B"
    Then I should see "Bob Jones, bjones@example.com (bjones)"

    When I follow "F"
    And I should see "Fred Robinson, frobinson@example.com (frobinson)"

  Scenario: Admin uploads users with claim codes
    When I enter the following into the bulk information area:
"""
John Smith,jsmith@example.com,123123
Bob Jones,bjones@example.com,234234
Fred Robinson,frobinson@example.com,345345
"""
    And I press "Upload Users"
    Then I should see "Successfully loaded 3 users"
    When I go to the admin "H Engage" demo page

    When I follow "J"
    Then I should see "John Smith, jsmith@example.com (123123)"

    When I follow "B"
    And I should see "Bob Jones, bjones@example.com (234234)"

    When I follow "F"
    And I should see "Fred Robinson, frobinson@example.com (345345)"

  Scenario: Admin uploads users with claim codes and unique IDs
    When I enter the following into the bulk information area:
"""
John Smith,jsmith@example.com,123123,johnny
Bob Jones,bjones@example.com,234234,bobby
Fred Robinson,frobinson@example.com,345345,freddy
"""
    And I press "Upload Users"
    Then I should see "Successfully loaded 3 users"
    When I go to the admin "H Engage" demo page

    When I follow "J"
    Then I should see "John Smith, jsmith@example.com (123123)"

    When I follow "B"
    Then I should see "Bob Jones, bjones@example.com (234234)"

    When I follow "F"
    Then I should see "Fred Robinson, frobinson@example.com (345345)"

    When "+14155551212" sends SMS "123123"
    And "+16175551212" sends SMS "234234"
    Then "+14155551212" should have received SMS "You've joined the H Engage game! Your user ID is johnny (text MYID if you forget). To play, text to this #."
    And "+16175551212" should have received SMS "You've joined the H Engage game! Your user ID is bobby (text MYID if you forget). To play, text to this #."
    When "+16175551212" sends SMS "johnny"
    And DJ cranks 10 times
    Then "+16175551212" should have received SMS "Got it, John Smith referred you to the game. Thanks for letting us know."
    And "+14155551212" should have received SMS "Bob Jones gave you credit for referring them to the game. Many thanks and 2000 bonus points!"

  Scenario: Linked to from demo page
    Given I am on the admin "H Engage" demo page
    And I follow "Bulk load users"
    Then I should be on the user bulk upload page for "H Engage"
