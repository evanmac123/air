Feature: User requests more info

  Background:
    Given the following user exists:
      | phone number |
      | +14152613077 |

  Scenario: User requests more info with MOREINFO
    When "+14152613077" sends SMS "moreinfo"
    Then "+14152613077" should have received an SMS "Great, we'll be in touch. Stay healthy!"

  Scenario: User requests more info with MORE INFO
    When "+14152613077" sends SMS "more info"
    Then "+14152613077" should have received an SMS "Great, we'll be in touch. Stay healthy!"

