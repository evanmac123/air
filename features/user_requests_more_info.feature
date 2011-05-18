Feature: User requests more info

  Background:
    Given the following user exists:
      | name | phone number |
      | Phil | +14152613077 |
    And "Phil" has the password "foo"

  Scenario: User requests more info with MOREINFO
    When "+14152613077" sends SMS "moreinfo"
    Then "+14152613077" should have received an SMS "Great, we'll be in touch. Stay healthy!"

  Scenario: User requests more info with MORE INFO
    When "+14152613077" sends SMS "more info"
    Then "+14152613077" should have received an SMS "Great, we'll be in touch. Stay healthy!"

  Scenario: User requests info through website
    When I sign in via the login page as "Phil/foo"
    And I enter the special command "moreinfo"
    Then I should see the success message "Great, we'll be in touch. Stay healthy!"
