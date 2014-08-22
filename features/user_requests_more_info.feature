Feature: User requests more info

  Background:
    Given the following claimed user exists:
      | name | email              | phone number |
      | Phil | phil@darnowsky.com | +14152613077 |
    And "Phil" has the password "foobar"

  Scenario: User requests more info
    When "+14152613077" sends SMS "info"
    Then "+14152613077" should have received an SMS "Great, we'll be in touch. Stay healthy!"
