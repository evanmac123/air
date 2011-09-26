Feature: Admin bulk loads users

  Background:
    Given the following demo exists:
      | company name |
      | H Engage     |
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
    Then I should see "John Smith, jsmith@example.com (jsmith)"
    And I should see "Bob Jones, bjones@example.com (bjones)"
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
    Then I should see "John Smith, jsmith@example.com (123123)"
    And I should see "Bob Jones, bjones@example.com (234234)"
    And I should see "Fred Robinson, frobinson@example.com (345345)"
