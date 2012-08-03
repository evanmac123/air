Feature: User requests more info

  Background:
    Given the following user exists:
      | name | phone number |
      | Phil | +14152613077 |
    And "Phil" has the password "foobar"

  Scenario: User requests more info
    When "+14152613077" sends SMS "info"
    Then "+14152613077" should have received an SMS "Great, we'll be in touch. Stay healthy!"

  Scenario: User requests info through website
    When I sign in via the login page as "Phil/foobar"
    And I enter the special command "info"
    Then I should see the success message "Great, we'll be in touch. Stay healthy!"
