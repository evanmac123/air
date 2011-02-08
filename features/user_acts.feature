Feature: User acts

  Scenario: User acts
    Given the following user exists:
      | name | phone number |
      | Dan  | +15087407520 |
    And a key exists with a name of "ate"
    And the following rule exists:
      | key       | value  | points |
      | name: ate | banana | 2      |
    When "+15087407520" sends SMS "ate banana"
    And I sign in via the login page
    And I go to the acts page
    Then I should see the following act:
      | name | act         | points |
      | Dan  | ate banana  | 2      |
