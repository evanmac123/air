Feature: The navbar does what it ought

  Scenario Outline: Link hooked up
    Given the following site admin exists:
      | name |
      | Joe  |
    And "Joe" has the password "foobar"

    When I sign in via the login page as "Joe/foobar"
    And I follow "<link text>"
    Then I should be on <page name>

    Scenarios:
      | link text  | page name                  |
      | Admin      | the admin page             |
      | Settings   | the settings page          |
      | Sign Out   | the sign in page           |
      | Home       | the activity page          |
      | My Profile | the profile page for "Joe" |
      | Directory  | the directory page         |
      | Help       | the help page              |
